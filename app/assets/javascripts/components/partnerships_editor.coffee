@PartnershipsEditor = React.createClass
  getInitialState: ->
    partnerships: @props.data

  getDefaultProps: ->
    partnerships: []

  addPartnership: (partnership) ->
    @state.partnerships.unshift partnership['partnerships'][0]
    @setState partnerships: @state.partnerships

  deletePartnership: (partnership) ->
    console.log partnership
    partnerships = @state.partnerships.slice()
    index = partnerships.indexOf partnership
    partnerships.splice index, 1
    @replaceState partnerships: partnerships
	
  updatePartnership: (partnership, data) ->
    index = @state.partnerships.indexOf partnership
    partnerships = React.addons.update(@state.partnerships, { $splice: [[index, 1, data]] })
    @replaceState partnerships: partnerships

  render: ->
    #console.log @state.partnerships
    React.DOM.div
      className: 'col-xs-12'
      React.DOM.h2
        className: 'title'
        'Partnerships'
      React.createElement PartnershipForm, handleNewPartnership: @addPartnership
      React.DOM.hr null
      React.DOM.table
        className: 'table table-responsive'
        React.DOM.thead null,
          React.DOM.tr null,
            React.DOM.th null, 'ID'
            React.DOM.th null, 'Nome'
            React.DOM.th null, 'Sede'
            React.DOM.th null, 'Referenti'
            React.DOM.th null, 'Attività'
            React.DOM.th null, 'Stipula'
            React.DOM.th null, 'Azioni'
        React.DOM.tbody null,
          for partnership in @state.partnerships
            React.createElement Partnership,
              key: partnership.id,
              partnership: partnership,
              handleDeletePartnership: @deletePartnership,
              handleEditPartnership: @updatePartnership