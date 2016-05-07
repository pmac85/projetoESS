cleanTable = (callback) ->
  $('#playersEdit').empty()
  callback()
  return

addPlayer = (name, team, position, value) ->




  $('#playersEdit').append '<aside class="col-md-6" style="padding-right: 2%;">
      <h3>Players</h3>
      <div class="row">
      <table id="listAllPlayers" class="table table-bordered table-hover" style="background-color: #FFFFFF">
        <thead>
        <tr class="info">
          <th class="text-center" style="background-color:lightgrey;">Name</th>
          <th class="text-center" style="background-color:lightgrey;">Team</th>
          <th class="text-center" style="background-color:lightgrey;">Position</th>
          <th class="text-center" style="background-color:lightgrey;">Value</th>
        </tr>
        </thead>
        <tbody>' +player +'</tbody>
      </table>
      </div>
    </aside>'
  return

dealFilters = ->
  positionFilter = $('#positionFilter option:selected').attr('id')
  valueFilter = $('#valueFilter option:selected').attr('id')
  $.ajax
    type: 'POST'
    url: '/teams/1/edit'
    dataType: 'json'
    data:
      positionFilter: positionFilter
      valueFilter: valueFilter
    success: (response) ->
      cleanTable ->
        i = 0
        while i < response.length
          addPlayer response[i].name, response[i].team, response[i].position, response[i].value
          i++
        return
      return
  return

$(document).on 'change', '#playerSearch', ->
  dealFilters()
  return