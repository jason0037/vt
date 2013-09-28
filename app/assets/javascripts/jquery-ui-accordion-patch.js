var cfg = ($.hoverintent = {
    sensitivity: 7,
    interval: 100
});

$.event.special.hoverintent = {
    setup: function() {
        $( this ).bind( "mouseover", jQuery.event.special.hoverintent.handler );
    },
    teardown: function() {
        $( this ).unbind( "mouseover", jQuery.event.special.hoverintent.handler );
    },
    handler: function( event ) {
        var that = this,
            args = arguments,
            target = $( event.target ),
            cX, cY, pX, pY;

        function track( event ) {
            cX = event.pageX;
            cY = event.pageY;
        };
        pX = event.pageX;
        pY = event.pageY;
        function clear() {
            target
                .unbind( "mousemove", track )
                .unbind( "mouseout", arguments.callee );
            clearTimeout( timeout );
        }
        function handler() {
            if ( ( Math.abs( pX - cX ) + Math.abs( pY - cY ) ) < cfg.sensitivity ) {
                clear();
                event.type = "hoverintent";
                // prevent accessing the original event since the new event
                // is fired asynchronously and the old event is no longer
                // usable (#6028)
                event.originalEvent = {};
                jQuery.event.handle.apply( that, args );
            } else {
                pX = cX;
                pY = cY;
                timeout = setTimeout( handler, cfg.interval );
            }
        }
        var timeout = setTimeout( handler, cfg.interval );
        target.mousemove( track ).mouseout( clear );
        return true;
    }
};