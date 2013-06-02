
spec = {
  "width": 600,
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

createHistogram = (school, dimensions, field) ->
  
  # Clear existing dimensions
  dimension = dimensions.shift()
  dimension.remove() if dimension
  
  # Create new dimension for given field
  dimension = school.dimension( (d) -> return d[field] )
  dimensions.push dimension
  
  # Get all entries and compute extent
  arr = dimension.top(Infinity)
  extent = d3.extent(arr, (d) -> return parseFloat(d[field]) )
  
  # Get DOM elements
  el = $("div[data-dimension='#{field}']")
  
  minEl = el.find("input[data-type='min']")
  maxEl = el.find("input[data-type='max']")
  
  minEl.attr("min", extent[0])
  minEl.attr("max", extent[1])
  
  maxEl.attr("min", extent[0])
  maxEl.attr("max", extent[1])
  
  # TODO: Define slider events
  
  # Apply filter based on extent (extent is needed to avoid NDAs)
  dimension.filter(extent)
  
  # Get the filtered rows and map to x-y coordinates
  arr = dimension.top(Infinity)
  values = arr.map( (d) -> return {"x": d.name_of_school, "y": d[field]})
  
  fieldSpec = spec
  
  fieldSpec.scales[1].domain = extent
  fieldSpec.data[0].values = values
  
  vg.parse.spec(fieldSpec, (chart) ->
    view = chart({el: "div[data-dimension='#{field}'] .viz"})
    view.renderer("svg")
    view.update()
    view.on('mouseover', (e, item) ->
      $("p[data-field='school']").text(item.datum.data.x)
      $("p[data-field='value']").text(item.datum.data.y)
    )
  )


parseData = (dataset) ->
  
  # Initialize cross filter object
  school = crossfilter(dataset)
  
  # Create storage for crossfilter dimensions
  dimensions = []
  
  # Get list of dimensions (e.g. columns)
  columns = Object.keys(dataset[0])
  
  createHistogram(school, dimensions, 'rate_of_misconducts_per_100_students_')
  createHistogram(school, dimensions, 'graduation_rate_')
  createHistogram(school, dimensions, 'average_student_attendance')
  createHistogram(school, dimensions, 'teachers_score')
  
  return
  
  # Get DOM elements
  selectEl = $("select.dimension")
  minimumEl = $("input[data-type='min']")
  maximumEl = $("input[data-type='max']")
  
  # Enable drop down
  selectEl.removeAttr('disabled')
  
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
          view = chart({el: '#vis'})
          view.renderer("svg")
          view.update()
          view.on('mouseover', (e, item) ->
            $("p[data-field='school']").text(item.datum.data.x)
            $("p[data-field='value']").text(item.datum.data.y)
          )
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
          view = chart({el: '#vis'})
          view.renderer("svg")
          view.update()
          view.on('mouseover', (e, item) ->
            $("p[data-field='school']").text(item.datum.data.x)
            $("p[data-field='value']").text(item.datum.data.y)
          )
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
      view = chart({el: '#vis'})
      view.renderer("svg")
      view.update()
      view.on('mouseover', (e, item) ->
        $("p[data-field='school']").text(item.datum.data.x)
        $("p[data-field='value']").text(item.datum.data.y)
      )
    )
    
  )

domReady = ->
  
  # Get data for Chicago Public School
  $.ajax('http://data.cityofchicago.org/resource/9xs2-f89t.json?elementary_or_high_school=HS')
    .done(parseData)
  
  # Set up interface
  $("a[data-goto='2']").on('click', (e) ->
    e.preventDefault()
    e.stopPropagation()
    $('.container').addClass('hide')
    $('.container:nth-child(2)').removeClass('hide')
  )


window.addEventListener('DOMContentLoaded', domReady, false)

# http://data.cityofchicago.org/resource/9xs2-f89t.json?elementary_or_high_school=HS&$select=ward