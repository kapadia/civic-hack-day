

parseData = (dataset) ->
  console.log 'parseData'
  school = crossfilter(dataset)
  dimension = school.dimension((d) -> return d.college_eligibility_)
  dimension.filter((d) -> return d < 90)
  arr = dimension.top(Infinity)
  console.log arr.length
  values = arr.map( (d) -> return {"x": d.name_of_school, "y": d.college_eligibility_})
  
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
        "domain": d3.extent(values, (d) -> return parseFloat(d.y))
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
  spec.data[0].values = values
  vg.parse.spec(spec, (chart) ->
    view = chart({el: '#vis'}).update()
  )

domReady = ->
  console.log 'domReady'
  $.ajax('http://data.cityofchicago.org/resource/9xs2-f89t.json')
    .done(parseData)


window.addEventListener('DOMContentLoaded', domReady, false)