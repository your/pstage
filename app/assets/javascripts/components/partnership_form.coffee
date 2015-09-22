@PartnershipForm = React.createClass
  getInitialState: ->
    partner_name: ''
    office_address: ''
    representatives_name: ''
    signing_date: ''
	
  handleChange: (e) ->
    name = e.target.name
    @setState "#{ name }": e.target.value

  valid: ->
    @state.partner_name && @state.office_address && @state.representatives_name

  handleSubmit: (e) ->
    e.preventDefault()
    $.post '', { partnership: @state }, (data) =>
      #console.log data
      @props.handleNewPartnership data
      @setState @getInitialState()
    , 'JSON'

  render: ->
    React.DOM.form
      className: 'form-inline'
      onSubmit: @handleSubmit
      React.DOM.div
        className: 'form-group'
        React.DOM.input
          type: 'text'
          className: 'form-control'
          placeholder: 'Partner Name'
          name: 'partner_name'
          value: @state.partner_name
          onChange: @handleChange
      React.DOM.div
        className: 'form-group'
        React.DOM.input
          type: 'text'
          className: 'form-control'
          placeholder: 'Office Address'
          name: 'office_address'
          value: @state.office_address
          onChange: @handleChange
      React.DOM.div
        className: 'form-group'
        React.DOM.input
          type: 'text'
          className: 'form-control'
          placeholder: 'Representatives'
          name: 'representatives_name'
          value: @state.representatives_name
          onChange: @handleChange
      React.DOM.div
        className: 'form-group'
        React.DOM.input
          type: 'text'
          className: 'form-control'
          placeholder: 'Signing Date'
          name: 'signing_date'
          value: @state.signing_date
          onChange: @handleChange
        React.DOM.button
          type: 'submit'
          className: 'btn btn-primary'
          disabled: !@valid()
          'Create partnership'