;(function (global, factory) {
    typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
    typeof define === 'function' && define.amd ? define(factory) :
    (global = global || self, global.html2xlsx = factory());
}(this, (function () { 'use strict';

	function isElement (obj) {
		try {
			//Using W3 DOM2 (works for FF, Opera and Chrome)
			return obj instanceof HTMLElement;
		} catch(e) {
			//Browsers not supporting W3 DOM2 don't have HTMLElement and
			//an exception is thrown and we end up here. Testing some
			//properties that all elements have (works on IE7)
			return (typeof obj==="object") &&
				(obj.nodeType===1) && (typeof obj.style === "object") &&
				(typeof obj.ownerDocument ==="object");
		}
	}

	function el2style (el){
		if(isElement(el))
			return el.style;
		else
			return '';
	}

	function size2pt (s) {
		const num = size2px(s);
		if (num > 0) {
			return num * 72 / 96;
		}
		return 12;
	}

	function size2px (s) {
		if (!s) return 0;

		const pt = s.match(/([.\d]+)pt/i);
		if (pt && pt.length === 2) {
			return parseFloat(pt[1], 10) * 96 / 72;
		}
		const em = s.match(/([.\d]+)em/i);
		if (em && em.length === 2) {
			return parseFloat(em[1], 10) * 16;
		}
		const px = s.match(/([.\d]+)px/i);
		if (px && px.length === 2) {
			return parseFloat(px[1], 10);
		}
		const pe = s.match(/([.\d]+)%/i);
		if (pe && pe.length === 2) {
			return (parseFloat(pe[1], 10) / 100) * 16;
		}
		return 0;
	}

	function color2argb (color){
  		const rgb = color.match(/^rgba?[\s+]?\([\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?/i);
  		if(rgb != null){
  			return ((rgb && rgb.length === 4) ? "FF" +
				("0" + parseInt(rgb[1],10).toString(16)).slice(-2) +
				("0" + parseInt(rgb[2],10).toString(16)).slice(-2) +
				("0" + parseInt(rgb[3],10).toString(16)).slice(-2) : '').toUpperCase()
  		} else {
			var shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
			const hex = color.replace(shorthandRegex, function(m, r, g, b) {
				return '#' + r + r + g + g + b + b;
			});
			return hex.replace('#', 'FF').toUpperCase();
  		}
	}

	function getBorder (css, type) {
		let color = css[`border-${type}-color`];
		let style = css[`border-${type}-style`];
		let width = css[`border-${type}-width`];

		if (!color) return null;

		width = size2px(width);
		if (width <= 0) return null;

		color = color2argb(color);

		if (style === 'dashed' || style === 'dotted' || style === 'double') {
			return { style, color };
		}
		style = 'thin';
		if (width >= 3 && width < 5) {
			style = 'medium';
		}
		if (width >= 5) {
			style = 'thick';
		}
		return { style, color };
	}

	function toXLSX(html, callback, options = {}){
		try {
			//var doctype = document.implementation.createDocumentType('html','-//W3C//DTD XHTML 1.0 Strict//EN','http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd');
			//const dom = document.implementation.createDocument('http://www.w3.org/1999/xhtml','html',doctype);
			//dom.documentElement.innerHTML = html;
			const file = new xlsx.File();
			var dom = document.createElement('div');
			dom.innerHTML = html;
			// very simple css inliner (only handle <style/> tags)
			//$(dom).inliner();

			$('table', dom).each((ti, table) => {
				const name = $(table).attr('name') || `Sheet${ti + 1}`;
				const sheet = file.addSheet(name);
				const maxW = [];
				const offsets = [];
				$('tr', table).each((hi, th) => {
					if (offsets[hi] === undefined) {
						offsets[hi] = 0;
					}
					let maxH = 20; // pt
					$('th, td', th).each((di, td) => {
						const rs = parseInt($(td).attr('rowspan'), 10) || 1;
						const cs = parseInt($(td).attr('colspan'), 10) || 1;
						for (let r = 0; r < rs; r++) {
							for (let c = 0; c < cs; c++) {
								sheet.cell(hi + r, offsets[hi] + c);
							}
						}

						const css = el2style($(td)[0]);
						const fsize = size2pt(css.fontSize);

						// Row Height & Col Width
						if (css.height) {
							const pt = size2pt(css.height);
							if (pt > maxH) {
								maxH = pt / rs;
							}
						}
						if (css.width) {
							if (!maxW[di]) {
								maxW[di] = 10;
							}
							const tmp = size2pt(css.width) / fsize;
							if (maxW[di] < tmp) {
								maxW[di] = tmp / cs;
							}
						}
						const style = new xlsx.Style();
						// Font
						style.font.color = color2argb(css.color || '#000');
						style.font.size = fsize;
						style.font.name = css.fontFamily || 'Verdana';
						style.font.bold = css.fontWeight === 'bold';
						style.font.italic = css.fontStyle === 'italic';
						style.font.underline = css.textDecoration === 'underline';
						// Fill
						const bgColor = css.backgroundColor;
						if (bgColor) {
							style.fill.patternType = 'solid';
							style.fill.fgColor = color2argb(bgColor);
						}

						// Border
						const left = getBorder(css, 'left');
						if (left) {
							style.border.left = left.style;
							style.border.leftColor = left.color;
						}
						const right = getBorder(css, 'right');
						if (right) {
							style.border.right = right.style;
							style.border.rightColor = right.color;
						}
						const top = getBorder(css, 'top');
						if (top) {
							style.border.top = top.style;
							style.border.topColor = top.color;
						}
						const bottom = getBorder(css, 'bottom');
						if (bottom) {
							style.border.bottom = bottom.style;
							style.border.bottomColor = bottom.color;
						}
						// Align
						const hMap = {
							left: 'left',
							right: 'right',
							center: 'center',
							justify: 'justify'
						};
						if (css.textAlign && hMap[css.textAlign]) {
							style.align.h = hMap[css.textAlign];
						}
						const vMap = {
							top: 'top',
							bottom: 'bottom',
							middle: 'center'
						};
						if (css.verticalAlign && vMap[css.verticalAlign]) {
							style.align.v = vMap[css.verticalAlign];
						}
						// Cell
						const cell = sheet.cell(hi, offsets[hi]);
						// Set value type
						const text = $(td).text().trim();
						const type = $(td).attr('type') || $(td).attr('data-type') || '';
						switch (type.toLowerCase()) {
							case 'number':
								cell.setNumber(text);
								break;
							case 'bool':
								cell.setBool(text === 'true' || text === '1');
								break;
							case 'formula':
								cell.setFormula(text);
								break;
							case 'date':
								cell.setDate(moment(text).toDate());
								break;
							case 'datetime':
								cell.setDateTime(moment(text).toDate());
								break;
							default:
								cell.value = text;
						}
						cell.style = style;

						if (rs > 1) {
							cell.vMerge = rs - 1;
						}
						if (cs > 1) {
							cell.hMerge = cs - 1;
						}

						for (let r = 0; r < rs; r++) {
							if (offsets[hi + r] === undefined) {
								offsets[hi + r] = 0;
							}
							offsets[hi + r] += cs;
						}					
					});
					sheet.rows[hi].setHeightCM(maxH * 0.03528);
				});
				// Set col width
				for (let i = 0; i < maxW.length; i++) {
					const w = maxW[i];
					if (w) {
						sheet.col(i).width = w;
					}
				}
			});

			callback(null, file);
		} catch(err){
			return callback(err);
		}
	};

	return toXLSX;
})));
