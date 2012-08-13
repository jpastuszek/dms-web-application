!function($) {
	var Numberpicker = function(element, options) {
		this.element = $(element);
		this.options = $.extend({}, $.fn.numberpicker.defaults, options);
		this.initVal = 0;

		this.element.on({
			focus: $.proxy(this.show, this),
			blur: $.proxy(this.hide, this),
			keyup: $.proxy(this.updateFromInput, this)
		});

		this.widget = $(this.options.template).appendTo('body');
	};

	Numberpicker.prototype = {
		constructor: Numberpicker,
		
		show: function(e) {
			e.stopPropagation();
			e.preventDefault();

			this.updateFromInput();
			this.initVal = this.getElementVal();

			this.element.trigger('show');

			this.place();
			$(window).on('resize', $.proxy(this.place, this));

			this.widget.show();
		},

		hide: function(e) {
			this.widget.hide();

			$(window).off('resize', this.place);

			this.element.trigger('hide');

			this.updateToInput();
		},

		getElementVal: function() {
			return parseInt(this.element.val()) || this.initVal;
		},

		getVal: function() {
			return parseInt(this.widget.find('td.bootstrap-numberpicker-number').text());
		},

		updateFromInput: function(e) {
			this.widget.find('td.bootstrap-numberpicker-number').text(this.getElementVal());
		},

		updateToInput: function(e) {
			this.element.val(this.getVal());
		},

		place: function(e) {
			var offset = this.element.offset();
			this.widget.css({
				top: offset.top + this.element.outerHeight(),
				left: offset.left
			});
		}
	};

	$.fn.numberpicker = function(options) {
		// capture optional method arguments
		var args = Array.prototype.slice.call(arguments, 1);

		return this.each(function () {
			var $this = $(this);
			var data = $this.data('numberpicker');

			// create new object
			if (!data) {
				return $this.data('numberpicker', (data = new Numberpicker(this, options)));
			}

			// call method instead
			if (data[options]) {
				return data[options].apply(data, args);
			} else {
				$.error( 'Method ' + options + ' does not exist on jQuery.numberpicker' );
			} 
		})
	};

	$.fn.numberpicker.defaults = {
		template: '<div class="bootstrap-numberpicker dropdown-menu">'+
			'<table>'+
				'<tr>'+
					'<td><a href="#" data-action="increment"><i class="icon-chevron-up"></i></a></td>'+
				'</tr>'+
				'<tr>'+
					'<td class="bootstrap-numberpicker-number"></td> '+
				'</tr>'+
				'<tr>'+
					'<td><a href="#" data-action="decrement"><i class="icon-chevron-down"></i></a></td>'+
				'</tr>'+
			'</table>'+
		'</div>'
	}

	$.fn.numberpicker.Constructor = Numberpicker;
}(window.jQuery);

