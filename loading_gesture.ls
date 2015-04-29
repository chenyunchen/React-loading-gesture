React = require('react')

{a, abbr, address, area, article, aside, audio, b, base, blockquote, br, button, canvas, caption, cite, code, col, colgroup, datalist, dd, del, details, dfn, dialog, div, dl, dt, em, fieldset, figcaption, figure, footer, form, h1, h2, h3, h4, h5, h6, header, hgroup, hr, i, iframe, img, input, ins, kbd, keygen, label, legend, li, link, main, map, mark, menu, menuitem, nav, object, ol, optgroup, option, p, q, section, select, span, strong, summary, table, tbody, td, textarea, tfoot, th, thead, time, title, tr, u, ul, video} = React.DOM

class loading-gesture extends React.Component
    (props,context)->
        super(props,context)
        @state = @getStoreState()
    getStoreState:~>
        return
            top: 0
            op: 0
            rot: 0
            spin: null
            left: Math.floor((global.innerWidth-64)/2)
    componentDidMount:!~>
        Hammer = require('hammerjs')
        h = new Hammer(React.findDOMNode(@refs.pan))
        h.get('pan').set({
            threshold: 0
        })
        h.on 'panmove', (event)!~>
            distance = event.distance
            if distance > @props.maxDistance
                distance = @props.maxDistance
            @setState({top:distance,op:Math.floor(distance/Math.floor(@props.maxDistance/10))/10,rot:Math.floor(distance/@props.maxDistance*360)+150})
        h.on 'pandown', (event)!~>
            if global.scrollY is 0 and event.distance > @props.maxDistance
                @pand = true
        h.on 'panend', (event)!~>
            if @pand and @props.disable
                date = new Date()
                @state.startTime = date.getTime()
                @props.eventTrigger!
                @pand = false
                val = setInterval(~>
                    distance = @state.top - 30
                    if distance <= @props.loadingDistance
                       distance = @props.loadingDistance
                       @setState({op:1, spin:'spin-animation', rot:0})
                       clearInterval(val)
                    @setState({top:distance})
                ,10)
            else
                val = setInterval(~>
                    distance = @state.top - 5
                    if distance <= 0
                       distance = 0
                       clearInterval(val)
                    @setState({top:distance,op:Math.floor(distance/Math.floor(@props.maxDistance/10))/10,rot: Math.floor(distance/@props.maxDistance*360)})
                ,10)
        @hammer = h
    shouldComponentUpdate:(nextProps, nextState)~>
        if not @props.disable and nextProps.disable
            date = new Date()
            intervalTime = @state.startTime - date.getTime()
            if intervalTime >= 2000
                loadingTime = 1
            else
                loadingTime = 2000 - intervalTime
            setTimeout(~>
                @setState({top:0, op:0, spin:null, rot:0})
            , loadingTime)
        return true
    render:->
        div do
            ref: 'pan'
            className: 'u-h-100p'
            img do
                className:@state.spin
                src: @props.image
                overflow: 'hidden'
                style:
                    left:@state.left+'px'
                    top:@state.top+'px'
                    '-webkit-transform': 'rotate('+@state.rot+'deg)'
                    '-moz-transform': 'rotate('+@state.rot+'deg)'
                    '-ms-transform': 'rotate('+@state.rot+'deg)'
                    transform: 'rotate('+@state.rot+'deg)'
                    '-webkit-transform-origin':'50% 50%'
                    '-moz-transform-origin':'50% 50%'
                    '-ms-transform-origin':'50% 50%'
                    transform-origin:'50% 50%'
                    opacity:@state.op
                    position:'absolute'

loading-gesture.contextTypes =
    executeAction: React.PropTypes.func.isRequired

module.exports = loading-gesture

