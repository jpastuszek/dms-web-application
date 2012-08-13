/* =========================================================
 * bootstrap-numberpicker.js 
 * =========================================================
 * Copyright 2012 Jakub Pastuszek
 *
 * Based on bootstrap-timepicker by:
 * Joris de Wit @joris_dewit
 * Gilbert @mindeavor
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================= */

!function($) {
	var Numberpicker = function(element, options) {
		this.options = $.extend({}, $.fn.numberpicker.defaults, options);
		this.initVal = this.options.min;

		this.element = $(element);
		this.element.on({
			focus: $.proxy(this.show, this),
			blur: $.proxy(this.hide, this),
			keyup: $.proxy(this.updateFromInput, this),
			keydown: $.proxy(this.handleKey, this)
		});

		this.picker = $(this.options.template).appendTo('body');
		this.picker.on({
			click: $.proxy(this.click, this),
			mousedown: $.proxy(this.mousedown, this)
		});
		this.value = this.picker.find('td.bootstrap-numberpicker-number');
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

			this.picker.show();
		},

		hide: function(e) {
			this.picker.hide();

			$(window).off('resize', this.place);

			this.element.trigger('hide');

			this.updateToInput();
		},

		sanitVal: function(val) {
			if (isNaN(val))
				val = this.initVal;
			if (val < this.options.min)
				val = this.options.min;
			return val;
		},

		getElementVal: function() {
			return this.sanitVal(parseInt(this.element.val()));
		},

		getVal: function() {
			return this.sanitVal(parseInt(this.value.text()));
		},

		setVal: function(val) {
			this.value.text(val);
		},

		updateFromInput: function(e) {
			this.value.text(this.getElementVal());
		},

		updateToInput: function(e) {
			this.element.val(this.getVal());
		},

		place: function(e) {
			var offset = this.element.offset();
			this.picker.css({
				top: offset.top + this.element.outerHeight(),
				left: offset.left
			});
		},

		click: function(e) {
			e.stopPropagation();
			e.preventDefault();

			var action = $(e.target).closest('a').data('action');
			if (action) {
				this[action]();
			}
		},

		mousedown: function(e) {
			e.stopPropagation();
			e.preventDefault();
		},

		increment: function(e) {
			this.setVal(this.sanitVal(this.getVal() + 1));
			this.updateToInput();
		},

		decrement: function(e) {
			this.setVal(this.sanitVal(this.getVal() - 1));
			this.updateToInput();
		},

		handleKey: function(e) {
			arrow = {up: 38, down: 40 };
			switch (e.which) {
			case arrow.up:
				this.increment();
				return false;
				break;
			case arrow.down:
				this.decrement();
				return false;
				break;
			}
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
		'</div>',

		min: 1
	}

	$.fn.numberpicker.Constructor = Numberpicker;
}(window.jQuery);

