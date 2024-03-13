(function() {
	$.fn.inliner = function(options) {
		console.log('inline function');
		var doc = $(this);
		var styles = $(this).find('style');

		$(styles).each(function(n, style){
			var rules = $(style)[0].sheet.cssRules;
			$(rules).each((idx, rule)=>{
				$(doc).find(rule.selectorText).each((num, selected)=>{
					$(rule.style).each(function(i, css){
						$(selected)[0].style[css] = rule.style[css];
					});
				});
			});
		});

		$(this).find('style').remove();
	};
}());