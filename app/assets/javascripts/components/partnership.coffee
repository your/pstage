@Partnership = React.createClass
  getInitialState: ->
    edit: false
	
  handleToggle: (e) ->
    e.preventDefault()
    @setState edit: !@state.edit
	
  handleDelete: (e) ->
    e.preventDefault()
    # yeah... jQuery doesn't have a $.delete shortcut method
    $.ajax
      method: 'DELETE'
      url: "/partnerships/#{ @props.partnership.id }"
      dataType: 'JSON'
      success: () =>
        console.log @props
        @props.handleDeletePartnership @props.partnership

  handleEdit: (e) ->
    e.preventDefault()
    data =
      partner_name: React.findDOMNode(@refs.partner_name).value
      office_address: React.findDOMNode(@refs.office_address).value
      representatives_name: React.findDOMNode(@refs.representatives_name).value
      activities: React.findDOMNode(@refs.activities).value
      signing_date: React.findDOMNode(@refs.signing_date).value
    # jQuery doesn't have a $.put shortcut method either
    $.ajax
      method: 'PUT'
      url: "/partnerships/#{ @props.partnership.id }"
      dataType: 'JSON'
      data:
        partnership: data
      success: (data) =>
        @setState edit: false
        @props.handleEditPartnership @props.partnership, data
		  
  partnershipRow: ->
    React.DOM.tr null,
      React.DOM.td null, @props.partnership.id
      React.DOM.td null, @props.partnership.partner_name
      React.DOM.td null, @props.partnership.office_address
      React.DOM.td null, @props.partnership.representatives_name
      React.DOM.td null, @props.partnership.activities
      React.DOM.td null, moment(@props.partnership.signing_date).format('DD/MM/YYYY')
      React.DOM.td null,
        React.DOM.a
          className: 'btn btn-default'
          onClick: @handleToggle
          'Edit'
        React.DOM.a
          className: 'btn btn-danger'
          onClick: @handleDelete
          'Delete'

  partnershipForm: ->
    React.DOM.tr null,
      React.DOM.td null,
        React.DOM.p
          className: 'form-control-static'
          @props.partnership.id
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @props.partnership.partner_name
          ref: 'partner_name'
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @props.partnership.office_address
          ref: 'office_address'
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @props.partnership.representatives_name
          ref: 'representatives_name'
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @props.partnership.activities
          ref: 'activities'
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @props.partnership.signing_date
          ref: 'signing_date'
      React.DOM.td null,
        React.DOM.a
          className: 'btn btn-default'
          onClick: @handleEdit
          'Update'
        React.DOM.a
          className: 'btn btn-danger'
          onClick: @handleToggle
          'Cancel'

  render: ->
    if @state.edit
      @partnershipForm()
    else
      @partnershipRow()