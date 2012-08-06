/* =========================================================
 * bootstrap-timepicker.js
 * http://www.github.com/jdewit/bootstrap-timepicker
 * =========================================================
 * Copyright 2012
 *
 * Created By:
 * Joris de Wit @joris_dewit
 * Gilbert @mindeavor
 *
 * Modified By:
 * Jakub Pastuszek (jpastuszek@gmail.com)
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

    "use strict"; // jshint ;_;

    /* TIMEPICKER PUBLIC CLASS DEFINITION
     * ================================== */
    var Timepicker = function(element, options) {
        this.$element = $(element);
        this.options = $.extend({}, $.fn.timepicker.defaults, options);
        this.minuteStep = this.options.minuteStep || this.minuteStep;
        this.template = this.options.template || this.template;
        this.open = false;
        this.init();
				this.updateFromElementVal();
    };

    Timepicker.prototype = {

        constructor: Timepicker

        , init: function () {
            this.$element
							.on('focus', $.proxy(this.show, this))
							.on('blur', $.proxy(this.hide, this))
							.on('blur', $.proxy(this.updateElement, this))
							.on('keyup', $.proxy(this.updateFromElementVal, this))
            ;
            
            switch(this.options.template) {
                case 'modal':
                    this.$widget = $(this.options.modalTemplate).appendTo('body');
                break;
                case 'dropdown':
                    this.$widget = $(this.options.dropdownTemplate).appendTo('body');
                break;
            }  

            this.$widget.on('click', $.proxy(this.click, this));
						this.$widget.on('mousedown', $.proxy(this.mousedown, this));
            //$('html').on('click.timepicker.data-api', $.proxy(this.hide, this));
        }

        , show: function(e) {
            e.stopPropagation();
            e.preventDefault();

            this.$element.trigger('show');

            var pos = $.extend({}, this.$element.offset(), {
                height: this.$element[0].offsetHeight
            });

            if (this.options.template === 'modal') {
//                this.$widget.css({
//                    top: pos.top + pos.height
//                })

                this.$widget.modal('show');
            } else {
                this.$widget.css({
                    top: pos.top + pos.height
                    , left: pos.left
                })

                if (!this.open) {
                    this.$widget.addClass('open');
                }
            }

            this.open = true;
            this.$element.trigger('shown');

            return this;
        }

        , hide: function(){
            this.$element.trigger('hide');
            
            if (this.options.template === 'modal') {
                this.$widget.modal('hide');
            } else {
                this.$widget.removeClass('open');
            }
            this.open = false;
            this.$element.trigger('hidden');

            return this;
        }

        , setTimeFromString: function(time) {
            var timeArray = time.split(':');

						if (timeArray.length >= 1)
							this.hour = parseInt(timeArray[0].replace(/^0/, '')) % 24;
						
						if (timeArray.length >= 2)
							this.minute = parseInt(timeArray[1].replace(/^0/, '')) % 60;

						if (isNaN(this.hour))
							this.hour = 0;
						if (isNaN(this.minute))
							this.minute = 0;

						if (this.open)
							this.updateWidget();
						else
							this.update();
        }

				, setTimeFromDate: function(dTime) {
					var hours = dTime.getHours();
					var minutes = Math.floor(dTime.getMinutes() / this.minuteStep) * this.minuteStep;

					this.hour = hours;
					this.minute = minutes;

					this.update();
				}

        , formatTime: function(hour, minute) {
            hour = hour < 10 ? '0' + hour : hour;
            minute = minute < 10 ? '0' + minute : minute;

            return hour + ':' + minute
        }

        , getTimeString: function() {
            return this.formatTime(this.hour, this.minute);
        }

        , updateElement: function() {
            var time = this.getTimeString();
            this.$element.val(time);
        }

        , updateWidget: function() {
            this.$widget
                .find('td.bootstrap-timepicker-hour').text(this.hour < 10 ? '0' + this.hour : this.hour).end()
                .find('td.bootstrap-timepicker-minute').text(this.minute < 10 ? '0' + this.minute : this.minute).end()
        }

        , update: function() {
            this.updateElement();
            this.updateWidget();
        }

        , updateFromElementVal: function () {
            var time = this.$element.val();
            if (time) {
                this.setTimeFromString(time);
            }
        }

        , click: function(e) {
            e.stopPropagation();
            e.preventDefault();

            var action = $(e.target).closest('a').data('action');
            if (action) {
                this[action]();
                this.update();
            }
        }

        , incrementHour: function() {
						this.hour = this.hour + 1;

            if (this.hour >= 24)
                this.hour = 0;
        }

        , decrementHour: function() {
						this.hour = this.hour - 1;

            if (this.hour < 0)
                this.hour = 23;
        }

        , incrementMinute: function() {
						var stepCorrection = this.minute % this.minuteStep;
						var newVal = this.minute;

						if (stepCorrection > 0)
							newVal -= stepCorrection;

						newVal += this.minuteStep;
							
            if (newVal > 59) {
                this.incrementHour();
                this.minute = newVal - 60;
            } else {
                this.minute = newVal;
            }
        }

        , decrementMinute: function() {
						var stepCorrection = this.minute % this.minuteStep;
						var newVal = this.minute;

						if (stepCorrection > 0)
							newVal -= stepCorrection;
						else
							newVal -= this.minuteStep;

            if (newVal < 0) {
                this.decrementHour();
                this.minute = newVal + 60;
            } else {
                this.minute = newVal;
            }
        }

				, mousedown: function(e){
					e.stopPropagation();
					e.preventDefault();
				}
    };


    /* TIMEPICKER PLUGIN DEFINITION
     * =========================== */

    $.fn.timepicker = function(options) {
				// capture optional method arguments
				var args = Array.prototype.slice.call(arguments, 1);

        return this.each(function () {
            var $this = $(this);
						var data = $this.data('timepicker');

						// create new object
            if (!data) {
                return $this.data('timepicker', (data = new Timepicker(this, options)));
            }

						// call method instead
						if (data[options]) {
								return data[options].apply(data, args);
						} else {
								$.error( 'Method ' + options + ' does not exist on jQuery.timepicker' );
						} 
        })
    }

    $.fn.timepicker.defaults = {
      minuteStep: 5
    , template: 'dropdown'
    , dropdownTemplate: '<div class="bootstrap-timepicker dropdown-menu">'+
                    '<table>'+
                        '<tr>'+
                            '<td><a href="#" data-action="incrementHour"><i class="icon-chevron-up"></i></a></td>'+
                            '<td class="separator"></td>'+
                            '<td><a href="#" data-action="incrementMinute"><i class="icon-chevron-up"></i></a></td>'+
                        '</tr>'+
                        '<tr>'+
                            '<td class="bootstrap-timepicker-hour"></td> '+
                            '<td class="separator">:</td>'+
                            '<td class="bootstrap-timepicker-minute"></td> '+
                        '</tr>'+
                        '<tr>'+
                            '<td><a href="#" data-action="decrementHour"><i class="icon-chevron-down"></i></a></td>'+
                            '<td class="separator"></td>'+
                            '<td><a href="#" data-action="decrementMinute"><i class="icon-chevron-down"></i></a></td>'+
                        '</tr>'+
                    '</table>'+
            '</div>'
    , modalTemplate: '<div class="bootstrap-timepicker modal hide fade in" style="top: 30%; margin-top: 0; width: 200px; margin-left: -100px;" data-backdrop="false">'+
                    '<div class="modal-header">'+
                        '<a href="#" class="close" data-action="hide">×</a>'+
                        '<h3>Pick a Time</h3>'+
                    '</div>'+
                    '<div class="modal-content">'+
                        '<table>'+
                            '<tr>'+
                                '<td><a href="#" data-action="incrementHour"><i class="icon-chevron-up"></i></a></td>'+
                                '<td class="separator"></td>'+
                                '<td><a href="#" data-action="incrementMinute"><i class="icon-chevron-up"></i></a></td>'+
                            '</tr>'+
                            '<tr>'+
                                '<td class="bootstrap-timepicker-hour"></td> '+
                                '<td class="separator">:</td>'+
                                '<td class="bootstrap-timepicker-minute"></td> '+
                            '</tr>'+
                            '<tr>'+
                                '<td><a href="#" data-action="decrementHour"><i class="icon-chevron-down"></i></a></td>'+
                                '<td class="separator"></td>'+
                                '<td><a href="#" data-action="decrementMinute"><i class="icon-chevron-down"></i></a></td>'+
                            '</tr>'+
                        '</table>'+
                    '</div>'+
                    '<div class="modal-footer">'+
                        '<a href="#" class="btn btn-primary" data-action="hide">Ok</a>'+
                    '</div>'+
                '</div>'
    }

    $.fn.timepicker.Constructor = Timepicker
}(window.jQuery);

