
spec = {
  "width": 800,
  "height": 300,
  "padding": {"top": 10, "left": 30, "bottom": 240, "right": 10},
  "data": [
    {
      "name": "table"
    }
  ],
  "scales": [
    {
      "name": "x",
      "type": "ordinal",
      "range": "width",
      "domain": {"data": "table", "field": "data.x"}
    },
    {
      "name": "y",
      "range": "height",
      "nice": true,
      # "domain": d3.extent(values, (d) -> return parseFloat(d.y))
    }
  ],
  "axes": [
    {
      "type": "x",
      "scale": "x",
      "properties": {
        "labels": {
          "angle": {"value": 90},
          "fontSize": {"value": 8},
          "align": {"value": "left"},
          "baseline": {"value": "middle"},
          "dx": {"value": 6}
        },
      }
    },
    {
      "type": "y",
      "scale": "y"
    }
  ],
  "marks": [
    {
      "type": "rect",
      "from": {"data": "table"},
      "properties": {
        "enter": {
          "x": {"scale": "x", "field": "data.x"},
          "width": {"scale": "x", "band": true, "offset": -1},
          "y": {"scale": "y", "field": "data.y"},
          "y2": {"scale": "y", "value": 0}
        },
        "update": {
          "fill": {"value": "steelblue"}
        },
        "hover": {
          "fill": {"value": "red"}
        }
      }
    }
  ]
}


parseData = (dataset) ->
  
  # Initialize cross filter object
  school = crossfilter(dataset)
  
  # Create storage for crossfilter dimensions
  dimensions = []
  
  # Get list of dimensions (e.g. columns)
  columns = Object.keys(dataset[0])
  
  # Get DOM elements
  selectEl = $("select.dimension")
  minimumEl = $("input[data-type='min']")
  maximumEl = $("input[data-type='max']")
  
  $("select.dimension").on('change', (e) ->
    
    # Clear any existing dimensions
    dimension = dimensions.shift()
    dimension.remove() if dimension
    
    # Get selected name and create dimension
    name = e.target.value
    dimension = school.dimension( (d) -> return d[name] )
    dimensions.push dimension
    
    # Get all entries and compute extent
    arr = dimension.top(Infinity)
    extent = d3.extent(arr, (d) -> return parseFloat(d[name]) )
    
    # Update min and max attribute for range inputs
    minimumEl.attr("min", extent[0])
    minimumEl.attr("max", extent[1])
    
    maximumEl.attr("min", extent[0])
    maximumEl.attr("max", extent[1])
    
    do (extent, dimension, name) ->
      
      # Clear previous handlers
      minimumEl.off()
      maximumEl.off()
      
      minimumEl.on('change', (e) ->
        min = e.target.value
        max = maximumEl.val()
        
        dimension.remove()
        dimension.filter([min, max])
        
        arr = dimension.top(Infinity)
        values = arr.map( (d) -> return {"x": d.name_of_school, "y": d[name]})
        
        spec.scales[1].domain = [min, max]
        spec.data[0].values = values

        vg.parse.spec(spec, (chart) ->
          view = chart({el: '#vis'}).update()
        )
        
      )
      
      maximumEl.on('change', (e) ->
        min = minimumEl.val()
        max = e.target.value
        
        dimension.remove()
        dimension.filter([min, max])
        
        arr = dimension.top(Infinity)
        values = arr.map( (d) -> return {"x": d.name_of_school, "y": d[name]})
        
        spec.scales[1].domain = [min, max]
        spec.data[0].values = values

        vg.parse.spec(spec, (chart) ->
          view = chart({el: '#vis'}).update()
        )
        
      )
    
    # Apply filter based on extent (extent is needed to avoid NDAs)
    dimension.filter(extent)
    
    # Get the filtered rows and map to x-y coordinates
    arr = dimension.top(Infinity)
    values = arr.map( (d) -> return {"x": d.name_of_school, "y": d[name]})
    
    spec.scales[1].domain = extent
    spec.data[0].values = values
    
    vg.parse.spec(spec, (chart) ->
      view = chart({el: '#vis'}).update()
    )
    
  )

domReady = ->
  console.log 'domReady'
  $.ajax('http://data.cityofchicago.org/resource/9xs2-f89t.json')
    .done(parseData)


window.addEventListener('DOMContentLoaded', domReady, false)