(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory(require('jszip')) :
  typeof define === 'function' && define.amd ? define(['jszip'], factory) :
  (global = global || self, global.xlsx = factory(global.JSZip));
}(this, function (Zip) { 'use strict';

  Zip = Zip && Zip.hasOwnProperty('default') ? Zip['default'] : Zip;

  function _defineProperty(obj, key, value) {
    if (key in obj) {
      Object.defineProperty(obj, key, {
        value: value,
        enumerable: true,
        configurable: true,
        writable: true
      });
    } else {
      obj[key] = value;
    }

    return obj;
  }

  var defineProperty = _defineProperty;

  function _objectSpread(target) {
    for (var i = 1; i < arguments.length; i++) {
      var source = arguments[i] != null ? arguments[i] : {};
      var ownKeys = Object.keys(source);

      if (typeof Object.getOwnPropertySymbols === 'function') {
        ownKeys = ownKeys.concat(Object.getOwnPropertySymbols(source).filter(function (sym) {
          return Object.getOwnPropertyDescriptor(source, sym).enumerable;
        }));
      }

      ownKeys.forEach(function (key) {
        defineProperty(target, key, source[key]);
      });
    }

    return target;
  }

  var objectSpread = _objectSpread;

  function _classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  }

  var classCallCheck = _classCallCheck;

  function _defineProperties(target, props) {
    for (var i = 0; i < props.length; i++) {
      var descriptor = props[i];
      descriptor.enumerable = descriptor.enumerable || false;
      descriptor.configurable = true;
      if ("value" in descriptor) descriptor.writable = true;
      Object.defineProperty(target, descriptor.key, descriptor);
    }
  }

  function _createClass(Constructor, protoProps, staticProps) {
    if (protoProps) _defineProperties(Constructor.prototype, protoProps);
    if (staticProps) _defineProperties(Constructor, staticProps);
    return Constructor;
  }

  var createClass = _createClass;

  function createCommonjsModule(fn, module) {
  	return module = { exports: {} }, fn(module, module.exports), module.exports;
  }

  var _typeof_1 = createCommonjsModule(function (module) {
  function _typeof2(obj) { if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof2 = function _typeof2(obj) { return typeof obj; }; } else { _typeof2 = function _typeof2(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof2(obj); }

  function _typeof(obj) {
    if (typeof Symbol === "function" && _typeof2(Symbol.iterator) === "symbol") {
      module.exports = _typeof = function _typeof(obj) {
        return _typeof2(obj);
      };
    } else {
      module.exports = _typeof = function _typeof(obj) {
        return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : _typeof2(obj);
      };
    }

    return _typeof(obj);
  }

  module.exports = _typeof;
  });

  function _assertThisInitialized(self) {
    if (self === void 0) {
      throw new ReferenceError("this hasn't been initialised - super() hasn't been called");
    }

    return self;
  }

  var assertThisInitialized = _assertThisInitialized;

  function _possibleConstructorReturn(self, call) {
    if (call && (_typeof_1(call) === "object" || typeof call === "function")) {
      return call;
    }

    return assertThisInitialized(self);
  }

  var possibleConstructorReturn = _possibleConstructorReturn;

  var setPrototypeOf = createCommonjsModule(function (module) {
  function _setPrototypeOf(o, p) {
    module.exports = _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) {
      o.__proto__ = p;
      return o;
    };

    return _setPrototypeOf(o, p);
  }

  module.exports = _setPrototypeOf;
  });

  function _inherits(subClass, superClass) {
    if (typeof superClass !== "function" && superClass !== null) {
      throw new TypeError("Super expression must either be null or a function");
    }

    subClass.prototype = Object.create(superClass && superClass.prototype, {
      constructor: {
        value: subClass,
        writable: true,
        configurable: true
      }
    });
    if (superClass) setPrototypeOf(subClass, superClass);
  }

  var inherits = _inherits;

  function _arrayWithHoles(arr) {
    if (Array.isArray(arr)) return arr;
  }

  var arrayWithHoles = _arrayWithHoles;

  function _iterableToArray(iter) {
    if (Symbol.iterator in Object(iter) || Object.prototype.toString.call(iter) === "[object Arguments]") return Array.from(iter);
  }

  var iterableToArray = _iterableToArray;

  function _nonIterableRest() {
    throw new TypeError("Invalid attempt to destructure non-iterable instance");
  }

  var nonIterableRest = _nonIterableRest;

  function _toArray(arr) {
    return arrayWithHoles(arr) || iterableToArray(arr) || nonIterableRest();
  }

  var toArray = _toArray;

  var getPrototypeOf = createCommonjsModule(function (module) {
  function _getPrototypeOf(o) {
    module.exports = _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) {
      return o.__proto__ || Object.getPrototypeOf(o);
    };
    return _getPrototypeOf(o);
  }

  module.exports = _getPrototypeOf;
  });

  function _superPropBase(object, property) {
    while (!Object.prototype.hasOwnProperty.call(object, property)) {
      object = getPrototypeOf(object);
      if (object === null) break;
    }

    return object;
  }

  var superPropBase = _superPropBase;

  var get = createCommonjsModule(function (module) {
  function _get(target, property, receiver) {
    if (typeof Reflect !== "undefined" && Reflect.get) {
      module.exports = _get = Reflect.get;
    } else {
      module.exports = _get = function _get(target, property, receiver) {
        var base = superPropBase(target, property);
        if (!base) return;
        var desc = Object.getOwnPropertyDescriptor(base, property);

        if (desc.get) {
          return desc.get.call(receiver);
        }

        return desc.value;
      };
    }

    return _get(target, property, receiver || target);
  }

  module.exports = _get;
  });

  function attrEscape(str) {
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/"/g, '&quot;').replace(/\t/g, '&#x9;').replace(/\n/g, '&#xA;').replace(/\r/g, '&#xD;');
  }

  function escape(str) {
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\r/g, '&#xD;');
  }

  var HEAD = Symbol('head');
  function props() {
    for (var _len = arguments.length, keys = new Array(_len), _key = 0; _key < _len; _key++) {
      keys[_key] = arguments[_key];
    }

    return function (target) {
      var _loop = function _loop() {
        var key = _keys[_i];
        target.elements.push({
          key: key,
          kind: 'method',
          placement: 'prototype',
          descriptor: {
            get: function get() {
              if (this.attributes) {
                return this.attributes[key];
              }
            },
            set: function set(value) {
              if (this.attributes === undefined) {
                this.attributes = {};
              }

              this.attributes[key] = value;
            },
            configurable: true,
            enumerable: true
          }
        });
      };

      for (var _i = 0, _keys = keys; _i < _keys.length; _i++) {
        _loop();
      }

      return target;
    };
  }
  var Node =
  /*#__PURE__*/
  function () {
    function Node() {
      var attributes = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
      var children = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];
      var name = arguments.length > 2 ? arguments[2] : undefined;

      classCallCheck(this, Node);

      for (var _i2 = 0, _Object$keys = Object.keys(attributes); _i2 < _Object$keys.length; _i2++) {
        var key = _Object$keys[_i2];
        this[key] = attributes[key];
      }

      this.children = children;
      this.__name = name || this.constructor.name.substring(1);
    }

    createClass(Node, [{
      key: "render",
      value: function render() {
        function walk(tree) {
          var name = tree.__name;
          var attributes = tree.attributes,
              children = tree.children;
          var tokens = [];

          if (tree[HEAD]) {
            tokens.push(tree[HEAD]);
          }

          tokens.push("<".concat(name));

          for (var _i3 = 0, _Object$keys2 = Object.keys(attributes || {}); _i3 < _Object$keys2.length; _i3++) {
            var key = _Object$keys2[_i3];
            var v = attributes[key];
            if (v === undefined) continue;

            if (typeof v === 'string') {
              v = attrEscape(v);
            }

            if (typeof v === 'boolean') {
              v = v ? 1 : 0;
            }

            tokens.push(" ".concat(key, "=\"").concat(v, "\""));
          }

          if (!children.length) {
            tokens.push('/>');
            return tokens;
          }

          tokens.push('>');
          var _iteratorNormalCompletion = true;
          var _didIteratorError = false;
          var _iteratorError = undefined;

          try {
            for (var _iterator = children[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
              var child = _step.value;

              if (child instanceof Node) {
                tokens.push(child.render());
              } else if (typeof child === 'string') {
                tokens.push(escape(child));
              } else {
                tokens.push(child.toString());
              }
            }
          } catch (err) {
            _didIteratorError = true;
            _iteratorError = err;
          } finally {
            try {
              if (!_iteratorNormalCompletion && _iterator["return"] != null) {
                _iterator["return"]();
              }
            } finally {
              if (_didIteratorError) {
                throw _iteratorError;
              }
            }
          }

          tokens.push("</".concat(name, ">"));
          return tokens;
        }

        return walk(this).join('');
      }
    }]);

    return Node;
  }();

  var NumFmtsCount = 163;
  /**
   * Number format table
   *
   * ```js
   * {
   *   0: 'general',
   *   1: '0',
   *   2: '0.00',
   *   3: '#,##0',
   *   4: '#,##0.00',
   *   9: '0%',
   *   10: '0.00%',
   *   11: '0.00e+00',
   *   12: '# ?/?',
   *   13: '# ??/??',
   *   14: 'mm-dd-yy',
   *   15: 'd-mmm-yy',
   *   16: 'd-mmm',
   *   17: 'mmm-yy',
   *   18: 'h:mm am/pm',
   *   19: 'h:mm:ss am/pm',
   *   20: 'h:mm',
   *   21: 'h:mm:ss',
   *   22: 'm/d/yy h:mm',
   *   37: '#,##0 ;(#,##0)',
   *   38: '#,##0 ;[red](#,##0)',
   *   39: '#,##0.00;(#,##0.00)',
   *   40: '#,##0.00;[red](#,##0.00)',
   *   41: '_(* #,##0_);_(* (#,##0);_(* "-"_);_(@_)',
   *   42: '_("$"* #,##0_);_("$* (#,##0);_("$"* "-"_);_(@_)',
   *   43: '_(* #,##0.00_);_(* (#,##0.00);_(* "-"??_);_(@_)',
   *   44: '_("$"* #,##0.00_);_("$"* (#,##0.00);_("$"* "-"??_);_(@_)',
   *   45: 'mm:ss',
   *   46: '[h]:mm:ss',
   *   47: 'mmss.0',
   *   48: '##0.0e+0',
   *   49: '@'
   * }
   * ```
   *
   * @type {Object}
   */

  var NumFmt = {
    0: 'general',
    1: '0',
    2: '0.00',
    3: '#,##0',
    4: '#,##0.00',
    9: '0%',
    10: '0.00%',
    11: '0.00e+00',
    12: '# ?/?',
    13: '# ??/??',
    14: 'mm-dd-yy',
    15: 'd-mmm-yy',
    16: 'd-mmm',
    17: 'mmm-yy',
    18: 'h:mm am/pm',
    19: 'h:mm:ss am/pm',
    20: 'h:mm',
    21: 'h:mm:ss',
    22: 'm/d/yy h:mm',
    37: '#,##0 ;(#,##0)',
    38: '#,##0 ;[red](#,##0)',
    39: '#,##0.00;(#,##0.00)',
    40: '#,##0.00;[red](#,##0.00)',
    41: '_(* #,##0_);_(* (#,##0);_(* "-"_);_(@_)',
    42: '_("$"* #,##0_);_("$* (#,##0);_("$"* "-"_);_(@_)',
    43: '_(* #,##0.00_);_(* (#,##0.00);_(* "-"??_);_(@_)',
    44: '_("$"* #,##0.00_);_("$"* (#,##0.00);_("$"* "-"??_);_(@_)',
    45: 'mm:ss',
    46: '[h]:mm:ss',
    47: 'mmss.0',
    48: '##0.0e+0',
    49: '@'
  };
  var NumFmtInv = {};

  for (var _i = 0, _Object$keys = Object.keys(NumFmt); _i < _Object$keys.length; _i++) {
    var k = _Object$keys[_i];
    NumFmtInv[NumFmt[k]] = k;
  } // AA => 26


  function col2num(colstr) {
    var d = 0;

    for (var i = 0; i !== colstr.length; ++i) {
      d = 26 * d + colstr.charCodeAt(i) - 64;
    }

    return d - 1;
  } // 26 => AA


  function num2col(col) {
    var s = '';

    for (++col; col; col = Math.floor((col - 1) / 26)) {
      s = String.fromCharCode((col - 1) % 26 + 65) + s;
    }

    return s;
  } // B3 => {x: 1, y: 2}


  function cid2coord(cid) {
    var temp = cid.match(/([A-Z]+)(\d+)/);
    return {
      x: col2num(temp[1]),
      y: parseInt(temp[2], 10) - 1
    };
  }

  function toExcelTime(d) {
    var unix = d.getTime() / 1000;
    return unix / 86400.0 + 25569.0;
  }

  var lib = /*#__PURE__*/Object.freeze({
    NumFmt: NumFmt,
    NumFmtInv: NumFmtInv,
    NumFmtsCount: NumFmtsCount,
    col2num: col2num,
    num2col: num2col,
    cid2coord: cid2coord,
    toExcelTime: toExcelTime
  });

  function _decorate(decorators, factory, superClass, mixins) { var api = _getDecoratorsApi(); if (mixins) { for (var i = 0; i < mixins.length; i++) { api = mixins[i](api); } } var r = factory(function initialize(O) { api.initializeInstanceElements(O, decorated.elements); }, superClass); var decorated = api.decorateClass(_coalesceClassElements(r.d.map(_createElementDescriptor)), decorators); api.initializeClassElements(r.F, decorated.elements); return api.runClassFinishers(r.F, decorated.finishers); }

  function _getDecoratorsApi() { _getDecoratorsApi = function _getDecoratorsApi() { return api; }; var api = { elementsDefinitionOrder: [["method"], ["field"]], initializeInstanceElements: function initializeInstanceElements(O, elements) { ["method", "field"].forEach(function (kind) { elements.forEach(function (element) { if (element.kind === kind && element.placement === "own") { this.defineClassElement(O, element); } }, this); }, this); }, initializeClassElements: function initializeClassElements(F, elements) { var proto = F.prototype; ["method", "field"].forEach(function (kind) { elements.forEach(function (element) { var placement = element.placement; if (element.kind === kind && (placement === "static" || placement === "prototype")) { var receiver = placement === "static" ? F : proto; this.defineClassElement(receiver, element); } }, this); }, this); }, defineClassElement: function defineClassElement(receiver, element) { var descriptor = element.descriptor; if (element.kind === "field") { var initializer = element.initializer; descriptor = { enumerable: descriptor.enumerable, writable: descriptor.writable, configurable: descriptor.configurable, value: initializer === void 0 ? void 0 : initializer.call(receiver) }; } Object.defineProperty(receiver, element.key, descriptor); }, decorateClass: function decorateClass(elements, decorators) { var newElements = []; var finishers = []; var placements = { "static": [], prototype: [], own: [] }; elements.forEach(function (element) { this.addElementPlacement(element, placements); }, this); elements.forEach(function (element) { if (!_hasDecorators(element)) return newElements.push(element); var elementFinishersExtras = this.decorateElement(element, placements); newElements.push(elementFinishersExtras.element); newElements.push.apply(newElements, elementFinishersExtras.extras); finishers.push.apply(finishers, elementFinishersExtras.finishers); }, this); if (!decorators) { return { elements: newElements, finishers: finishers }; } var result = this.decorateConstructor(newElements, decorators); finishers.push.apply(finishers, result.finishers); result.finishers = finishers; return result; }, addElementPlacement: function addElementPlacement(element, placements, silent) { var keys = placements[element.placement]; if (!silent && keys.indexOf(element.key) !== -1) { throw new TypeError("Duplicated element (" + element.key + ")"); } keys.push(element.key); }, decorateElement: function decorateElement(element, placements) { var extras = []; var finishers = []; for (var decorators = element.decorators, i = decorators.length - 1; i >= 0; i--) { var keys = placements[element.placement]; keys.splice(keys.indexOf(element.key), 1); var elementObject = this.fromElementDescriptor(element); var elementFinisherExtras = this.toElementFinisherExtras((0, decorators[i])(elementObject) || elementObject); element = elementFinisherExtras.element; this.addElementPlacement(element, placements); if (elementFinisherExtras.finisher) { finishers.push(elementFinisherExtras.finisher); } var newExtras = elementFinisherExtras.extras; if (newExtras) { for (var j = 0; j < newExtras.length; j++) { this.addElementPlacement(newExtras[j], placements); } extras.push.apply(extras, newExtras); } } return { element: element, finishers: finishers, extras: extras }; }, decorateConstructor: function decorateConstructor(elements, decorators) { var finishers = []; for (var i = decorators.length - 1; i >= 0; i--) { var obj = this.fromClassDescriptor(elements); var elementsAndFinisher = this.toClassDescriptor((0, decorators[i])(obj) || obj); if (elementsAndFinisher.finisher !== undefined) { finishers.push(elementsAndFinisher.finisher); } if (elementsAndFinisher.elements !== undefined) { elements = elementsAndFinisher.elements; for (var j = 0; j < elements.length - 1; j++) { for (var k = j + 1; k < elements.length; k++) { if (elements[j].key === elements[k].key && elements[j].placement === elements[k].placement) { throw new TypeError("Duplicated element (" + elements[j].key + ")"); } } } } } return { elements: elements, finishers: finishers }; }, fromElementDescriptor: function fromElementDescriptor(element) { var obj = { kind: element.kind, key: element.key, placement: element.placement, descriptor: element.descriptor }; var desc = { value: "Descriptor", configurable: true }; Object.defineProperty(obj, Symbol.toStringTag, desc); if (element.kind === "field") obj.initializer = element.initializer; return obj; }, toElementDescriptors: function toElementDescriptors(elementObjects) { if (elementObjects === undefined) return; return toArray(elementObjects).map(function (elementObject) { var element = this.toElementDescriptor(elementObject); this.disallowProperty(elementObject, "finisher", "An element descriptor"); this.disallowProperty(elementObject, "extras", "An element descriptor"); return element; }, this); }, toElementDescriptor: function toElementDescriptor(elementObject) { var kind = String(elementObject.kind); if (kind !== "method" && kind !== "field") { throw new TypeError('An element descriptor\'s .kind property must be either "method" or' + ' "field", but a decorator created an element descriptor with' + ' .kind "' + kind + '"'); } var key = _toPropertyKey(elementObject.key); var placement = String(elementObject.placement); if (placement !== "static" && placement !== "prototype" && placement !== "own") { throw new TypeError('An element descriptor\'s .placement property must be one of "static",' + ' "prototype" or "own", but a decorator created an element descriptor' + ' with .placement "' + placement + '"'); } var descriptor = elementObject.descriptor; this.disallowProperty(elementObject, "elements", "An element descriptor"); var element = { kind: kind, key: key, placement: placement, descriptor: Object.assign({}, descriptor) }; if (kind !== "field") { this.disallowProperty(elementObject, "initializer", "A method descriptor"); } else { this.disallowProperty(descriptor, "get", "The property descriptor of a field descriptor"); this.disallowProperty(descriptor, "set", "The property descriptor of a field descriptor"); this.disallowProperty(descriptor, "value", "The property descriptor of a field descriptor"); element.initializer = elementObject.initializer; } return element; }, toElementFinisherExtras: function toElementFinisherExtras(elementObject) { var element = this.toElementDescriptor(elementObject); var finisher = _optionalCallableProperty(elementObject, "finisher"); var extras = this.toElementDescriptors(elementObject.extras); return { element: element, finisher: finisher, extras: extras }; }, fromClassDescriptor: function fromClassDescriptor(elements) { var obj = { kind: "class", elements: elements.map(this.fromElementDescriptor, this) }; var desc = { value: "Descriptor", configurable: true }; Object.defineProperty(obj, Symbol.toStringTag, desc); return obj; }, toClassDescriptor: function toClassDescriptor(obj) { var kind = String(obj.kind); if (kind !== "class") { throw new TypeError('A class descriptor\'s .kind property must be "class", but a decorator' + ' created a class descriptor with .kind "' + kind + '"'); } this.disallowProperty(obj, "key", "A class descriptor"); this.disallowProperty(obj, "placement", "A class descriptor"); this.disallowProperty(obj, "descriptor", "A class descriptor"); this.disallowProperty(obj, "initializer", "A class descriptor"); this.disallowProperty(obj, "extras", "A class descriptor"); var finisher = _optionalCallableProperty(obj, "finisher"); var elements = this.toElementDescriptors(obj.elements); return { elements: elements, finisher: finisher }; }, runClassFinishers: function runClassFinishers(constructor, finishers) { for (var i = 0; i < finishers.length; i++) { var newConstructor = (0, finishers[i])(constructor); if (newConstructor !== undefined) { if (typeof newConstructor !== "function") { throw new TypeError("Finishers must return a constructor."); } constructor = newConstructor; } } return constructor; }, disallowProperty: function disallowProperty(obj, name, objectType) { if (obj[name] !== undefined) { throw new TypeError(objectType + " can't have a ." + name + " property."); } } }; return api; }

  function _createElementDescriptor(def) { var key = _toPropertyKey(def.key); var descriptor; if (def.kind === "method") { descriptor = { value: def.value, writable: true, configurable: true, enumerable: false }; } else if (def.kind === "get") { descriptor = { get: def.value, configurable: true, enumerable: false }; } else if (def.kind === "set") { descriptor = { set: def.value, configurable: true, enumerable: false }; } else if (def.kind === "field") { descriptor = { configurable: true, writable: true, enumerable: true }; } var element = { kind: def.kind === "field" ? "field" : "method", key: key, placement: def["static"] ? "static" : def.kind === "field" ? "own" : "prototype", descriptor: descriptor }; if (def.decorators) element.decorators = def.decorators; if (def.kind === "field") element.initializer = def.value; return element; }

  function _coalesceGetterSetter(element, other) { if (element.descriptor.get !== undefined) { other.descriptor.get = element.descriptor.get; } else { other.descriptor.set = element.descriptor.set; } }

  function _coalesceClassElements(elements) { var newElements = []; var isSameElement = function isSameElement(other) { return other.kind === "method" && other.key === element.key && other.placement === element.placement; }; for (var i = 0; i < elements.length; i++) { var element = elements[i]; var other; if (element.kind === "method" && (other = newElements.find(isSameElement))) { if (_isDataDescriptor(element.descriptor) || _isDataDescriptor(other.descriptor)) { if (_hasDecorators(element) || _hasDecorators(other)) { throw new ReferenceError("Duplicated methods (" + element.key + ") can't be decorated."); } other.descriptor = element.descriptor; } else { if (_hasDecorators(element)) { if (_hasDecorators(other)) { throw new ReferenceError("Decorators can't be placed on different accessors with for " + "the same property (" + element.key + ")."); } other.decorators = element.decorators; } _coalesceGetterSetter(element, other); } } else { newElements.push(element); } } return newElements; }

  function _hasDecorators(element) { return element.decorators && element.decorators.length; }

  function _isDataDescriptor(desc) { return desc !== undefined && !(desc.value === undefined && desc.writable === undefined); }

  function _optionalCallableProperty(obj, name) { var value = obj[name]; if (value !== undefined && typeof value !== "function") { throw new TypeError("Expected '" + name + "' to be a function"); } return value; }

  function _toPropertyKey(arg) { var key = _toPrimitive(arg, "string"); return _typeof_1(key) === "symbol" ? key : String(key); }

  function _toPrimitive(input, hint) { if (_typeof_1(input) !== "object" || input === null) return input; var prim = input[Symbol.toPrimitive]; if (prim !== undefined) { var res = prim.call(input, hint || "default"); if (_typeof_1(res) !== "object") return res; throw new TypeError("@@toPrimitive must return a primitive value."); } return (hint === "string" ? String : Number)(input); }
  var XstyleSheet = _decorate([props('xmlns')], function (_initialize, _Node) {
    var XstyleSheet =
    /*#__PURE__*/
    function (_Node2) {
      inherits(XstyleSheet, _Node2);

      function XstyleSheet(_ref, children) {
        var _this;

        var _ref$xmlns = _ref.xmlns,
            xmlns = _ref$xmlns === void 0 ? 'http://schemas.openxmlformats.org/spreadsheetml/2006/main' : _ref$xmlns;

        classCallCheck(this, XstyleSheet);

        _this = possibleConstructorReturn(this, getPrototypeOf(XstyleSheet).call(this, {
          xmlns: xmlns
        }, children));

        _initialize(assertThisInitialized(_this));

        _this[HEAD] = '<?xml version="1.0" encoding="UTF-8"?>';
        return _this;
      }

      return XstyleSheet;
    }(_Node);

    return {
      F: XstyleSheet,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "styleSheet";
        }
      }, {
        kind: "field",
        key: "fonts",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "fills",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "borders",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "cellStyles",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "cellStyleXfs",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "cellXfs",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "numFmts",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "numFmtRefTable",
        value: function value() {
          return {};
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          this.children = [];
          if (this.numFmts) this.children.push(this.numFmts);
          if (this.fonts) this.children.push(this.fonts);
          if (this.fills) this.children.push(this.fills);
          if (this.borders) this.children.push(this.borders);
          if (this.cellStyleXfs) this.children.push(this.cellStyleXfs);
          if (this.cellXfs) this.children.push(this.cellXfs);
          if (this.cellStyles) this.children.push(this.cellStyles);
          return get(getPrototypeOf(XstyleSheet.prototype), "render", this).call(this);
        }
      }, {
        kind: "method",
        key: "reset",
        value: function reset() {
          this.children = [];
          this.fonts = new Xfonts();
          this.fills = new Xfills();
          this.borders = new Xborders();
          this.cellXfs = new XcellXfs({
            count: 1
          }, [new Xxf()]);
          this.numFmts = new XnumFmts();
          this.addBorder(new Xborder({
            left: {
              style: 'none'
            },
            right: {
              style: 'none'
            },
            top: {
              style: 'none'
            },
            bottom: {
              style: 'none'
            }
          }));
        }
      }, {
        kind: "method",
        key: "addFont",
        value: function addFont(xFont) {
          if (!xFont.name) return 0;
          var list = this.fonts.children;
          var len = list.length;

          for (var i = 0; i < list.length; i++) {
            if (xFont.equals(list[i])) return i;
          }

          list.push(xFont);
          this.fonts.count = list.length;
          return len;
        }
      }, {
        kind: "method",
        key: "addFill",
        value: function addFill(xFill) {
          var list = this.fills.children;
          var len = list.length;

          for (var i = 0; i < list.length; i++) {
            if (xFill.equals(list[i])) return i;
          }

          list.push(xFill);
          this.fills.count = list.length;
          return len;
        }
      }, {
        kind: "method",
        key: "addBorder",
        value: function addBorder(xBorder) {
          var list = this.borders.children;
          var len = list.length;

          for (var i = 0; i < list.length; i++) {
            if (xBorder.equals(list[i])) return i;
          }

          list.push(xBorder);
          this.borders.count = list.length;
          return len;
        }
      }, {
        kind: "method",
        key: "addCellXf",
        value: function addCellXf(xXf) {
          var list = this.cellXfs.children;
          var len = list.length;

          for (var i = 0; i < list.length; i++) {
            if (xXf.equals(list[i])) return i;
          }

          list.push(xXf);
          this.cellXfs.count = list.length;
          return len;
        }
      }, {
        kind: "method",
        key: "addNumFmt",
        value: function addNumFmt(xNumFmt) {
          if (xNumFmt.numFmtId <= NumFmtsCount) return;

          if (this.numFmtRefTable[xNumFmt.numFmtId] === undefined) {
            this.numFmts.children.push(xNumFmt);
            this.numFmts.count = this.numFmts.children.length;
            this.numFmtRefTable[xNumFmt.numFmtId] = xNumFmt;
          }
        }
      }, {
        kind: "method",
        key: "newNumFmt",
        value: function newNumFmt(formatCode) {
          if (!formatCode) return new XnumFmt({
            numFmtId: 0,
            formatCode: 'general'
          });
          var numFmtId = NumFmtInv[formatCode];

          if (numFmtId !== undefined) {
            return new XnumFmt({
              numFmtId: numFmtId,
              formatCode: formatCode
            });
          }

          var _iteratorNormalCompletion = true;
          var _didIteratorError = false;
          var _iteratorError = undefined;

          try {
            for (var _iterator = this.numFmts.children[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
              var numFmt = _step.value;
              if (formatCode === numFmt.formatCode) return numFmt;
            }
          } catch (err) {
            _didIteratorError = true;
            _iteratorError = err;
          } finally {
            try {
              if (!_iteratorNormalCompletion && _iterator["return"] != null) {
                _iterator["return"]();
              }
            } finally {
              if (_didIteratorError) {
                throw _iteratorError;
              }
            }
          }

          numFmtId = NumFmtsCount + 1;

          do {
            if (this.numFmtRefTable[numFmtId]) {
              numFmtId++;
            } else {
              this.addNumFmt(new XnumFmt({
                numFmtId: numFmtId,
                formatCode: formatCode
              }));
              break;
            }
          } while (1);

          return new XnumFmt({
            numFmtId: numFmtId,
            formatCode: formatCode
          });
        }
      }]
    };
  }, Node);
  var XnumFmts = _decorate([props('count')], function (_initialize2, _Node3) {
    var XnumFmts =
    /*#__PURE__*/
    function (_Node4) {
      inherits(XnumFmts, _Node4);

      function XnumFmts() {
        var _getPrototypeOf2;

        var _this2;

        classCallCheck(this, XnumFmts);

        for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
          args[_key] = arguments[_key];
        }

        _this2 = possibleConstructorReturn(this, (_getPrototypeOf2 = getPrototypeOf(XnumFmts)).call.apply(_getPrototypeOf2, [this].concat(args)));

        _initialize2(assertThisInitialized(_this2));

        return _this2;
      }

      return XnumFmts;
    }(_Node3);

    return {
      F: XnumFmts,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "numFmts";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          if (this.count) return get(getPrototypeOf(XnumFmts.prototype), "render", this).call(this);
          return '';
        }
      }]
    };
  }, Node);
  var XnumFmt = _decorate([props('numFmtId', 'formatCode')], function (_initialize3, _Node5) {
    var XnumFmt =
    /*#__PURE__*/
    function (_Node6) {
      inherits(XnumFmt, _Node6);

      function XnumFmt() {
        var _getPrototypeOf3;

        var _this3;

        classCallCheck(this, XnumFmt);

        for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
          args[_key2] = arguments[_key2];
        }

        _this3 = possibleConstructorReturn(this, (_getPrototypeOf3 = getPrototypeOf(XnumFmt)).call.apply(_getPrototypeOf3, [this].concat(args)));

        _initialize3(assertThisInitialized(_this3));

        return _this3;
      }

      return XnumFmt;
    }(_Node5);

    return {
      F: XnumFmt,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "numFmt";
        }
      }]
    };
  }, Node);
  var Xfonts = _decorate([props('count')], function (_initialize4, _Node7) {
    var Xfonts =
    /*#__PURE__*/
    function (_Node8) {
      inherits(Xfonts, _Node8);

      function Xfonts() {
        var _getPrototypeOf4;

        var _this4;

        classCallCheck(this, Xfonts);

        for (var _len3 = arguments.length, args = new Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
          args[_key3] = arguments[_key3];
        }

        _this4 = possibleConstructorReturn(this, (_getPrototypeOf4 = getPrototypeOf(Xfonts)).call.apply(_getPrototypeOf4, [this].concat(args)));

        _initialize4(assertThisInitialized(_this4));

        return _this4;
      }

      return Xfonts;
    }(_Node7);

    return {
      F: Xfonts,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "fonts";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          if (this.count) return get(getPrototypeOf(Xfonts.prototype), "render", this).call(this);
          return '';
        }
      }]
    };
  }, Node);
  var Xfont = _decorate([props('sz', 'name', 'family', 'charset', 'color', 'b', 'i', 'u')], function (_initialize5, _Node9) {
    var Xfont =
    /*#__PURE__*/
    function (_Node10) {
      inherits(Xfont, _Node10);

      function Xfont() {
        var _getPrototypeOf5;

        var _this5;

        classCallCheck(this, Xfont);

        for (var _len4 = arguments.length, args = new Array(_len4), _key4 = 0; _key4 < _len4; _key4++) {
          args[_key4] = arguments[_key4];
        }

        _this5 = possibleConstructorReturn(this, (_getPrototypeOf5 = getPrototypeOf(Xfont)).call.apply(_getPrototypeOf5, [this].concat(args)));

        _initialize5(assertThisInitialized(_this5));

        return _this5;
      }

      return Xfont;
    }(_Node9);

    return {
      F: Xfont,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "font";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          var str = '<font>';
          if (this.sz) str += "<sz val=\"".concat(this.sz, "\"/>");
          if (this.name) str += "<name val=\"".concat(this.name, "\"/>");
          if (this.family) str += "<family val=\"".concat(this.family, "\"/>");
          if (this.charset) str += "<charset val=\"".concat(this.charset, "\"/>");
          if (this.color) str += "<color rgb=\"".concat(this.color, "\"/>");
          if (this.b) str += "<b/>";
          if (this.i) str += "<i/>";
          if (this.u) str += "<u/>";
          return str + '</font>';
        }
      }, {
        kind: "method",
        key: "equals",
        value: function equals(o) {
          return this.sz === o.sz && this.name === o.name && this.family === o.family && this.charset === o.charset && this.color === o.color && this.b === o.b && this.i === o.i && this.u === o.u;
        }
      }]
    };
  }, Node);
  var Xfills = _decorate([props('count')], function (_initialize6, _Node11) {
    var Xfills =
    /*#__PURE__*/
    function (_Node12) {
      inherits(Xfills, _Node12);

      function Xfills() {
        var _getPrototypeOf6;

        var _this6;

        classCallCheck(this, Xfills);

        for (var _len5 = arguments.length, args = new Array(_len5), _key5 = 0; _key5 < _len5; _key5++) {
          args[_key5] = arguments[_key5];
        }

        _this6 = possibleConstructorReturn(this, (_getPrototypeOf6 = getPrototypeOf(Xfills)).call.apply(_getPrototypeOf6, [this].concat(args)));

        _initialize6(assertThisInitialized(_this6));

        return _this6;
      }

      return Xfills;
    }(_Node11);

    return {
      F: Xfills,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "fills";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          if (this.count) return get(getPrototypeOf(Xfills.prototype), "render", this).call(this);
          return '';
        }
      }]
    };
  }, Node);
  var Xfill = _decorate([props('patternFill')], function (_initialize7, _Node13) {
    var Xfill =
    /*#__PURE__*/
    function (_Node14) {
      inherits(Xfill, _Node14);

      function Xfill() {
        var _getPrototypeOf7;

        var _this7;

        classCallCheck(this, Xfill);

        for (var _len6 = arguments.length, args = new Array(_len6), _key6 = 0; _key6 < _len6; _key6++) {
          args[_key6] = arguments[_key6];
        }

        _this7 = possibleConstructorReturn(this, (_getPrototypeOf7 = getPrototypeOf(Xfill)).call.apply(_getPrototypeOf7, [this].concat(args)));

        _initialize7(assertThisInitialized(_this7));

        return _this7;
      }

      return Xfill;
    }(_Node13);

    return {
      F: Xfill,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "fill";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          return "<fill>".concat(this.patternFill.render(), "</fill>");
        }
      }, {
        kind: "method",
        key: "equals",
        value: function equals(o) {
          var pf1 = this.patternFill;
          var pf2 = o.patternFill;

          if (pf1 && pf2) {
            return pf1.patternType === pf2.patternType && pf1.fgColor === pf2.fgColor && pf1.bgColor === pf2.bgColor;
          }

          return !pf1 && !pf2;
        }
      }]
    };
  }, Node);
  var XpatternFill = _decorate([props('patternType', 'fgColor', 'bgColor')], function (_initialize8, _Node15) {
    var XpatternFill =
    /*#__PURE__*/
    function (_Node16) {
      inherits(XpatternFill, _Node16);

      function XpatternFill() {
        var _getPrototypeOf8;

        var _this8;

        classCallCheck(this, XpatternFill);

        for (var _len7 = arguments.length, args = new Array(_len7), _key7 = 0; _key7 < _len7; _key7++) {
          args[_key7] = arguments[_key7];
        }

        _this8 = possibleConstructorReturn(this, (_getPrototypeOf8 = getPrototypeOf(XpatternFill)).call.apply(_getPrototypeOf8, [this].concat(args)));

        _initialize8(assertThisInitialized(_this8));

        return _this8;
      }

      return XpatternFill;
    }(_Node15);

    return {
      F: XpatternFill,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "patternFill";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          var str = "<patternFill patternType=\"".concat(this.patternType, "\">");
          if (this.fgColor) str += "<fgColor rgb=\"".concat(this.fgColor, "\"/>");
          if (this.bgColor) str += "<bgColor rgb=\"".concat(this.bgColor, "\"/>");
          return str + '</patternFill>';
        }
      }]
    };
  }, Node);
  var Xborders = _decorate([props('count')], function (_initialize9, _Node17) {
    var Xborders =
    /*#__PURE__*/
    function (_Node18) {
      inherits(Xborders, _Node18);

      function Xborders() {
        var _getPrototypeOf9;

        var _this9;

        classCallCheck(this, Xborders);

        for (var _len8 = arguments.length, args = new Array(_len8), _key8 = 0; _key8 < _len8; _key8++) {
          args[_key8] = arguments[_key8];
        }

        _this9 = possibleConstructorReturn(this, (_getPrototypeOf9 = getPrototypeOf(Xborders)).call.apply(_getPrototypeOf9, [this].concat(args)));

        _initialize9(assertThisInitialized(_this9));

        return _this9;
      }

      return Xborders;
    }(_Node17);

    return {
      F: Xborders,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "borders";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          if (this.count) return get(getPrototypeOf(Xborders.prototype), "render", this).call(this);
          return '';
        }
      }]
    };
  }, Node);
  var Xborder = _decorate([props('left', 'right', 'top', 'bottom')], function (_initialize10, _Node19) {
    var Xborder =
    /*#__PURE__*/
    function (_Node20) {
      inherits(Xborder, _Node20);

      function Xborder() {
        var _getPrototypeOf10;

        var _this10;

        classCallCheck(this, Xborder);

        for (var _len9 = arguments.length, args = new Array(_len9), _key9 = 0; _key9 < _len9; _key9++) {
          args[_key9] = arguments[_key9];
        }

        _this10 = possibleConstructorReturn(this, (_getPrototypeOf10 = getPrototypeOf(Xborder)).call.apply(_getPrototypeOf10, [this].concat(args)));

        _initialize10(assertThisInitialized(_this10));

        return _this10;
      }

      return Xborder;
    }(_Node19);

    return {
      F: Xborder,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "border";
        }
      }, {
        kind: "method",
        key: "_renderLine",
        value: function _renderLine(pos) {
          var posVal = this[pos];
          if (!posVal) return '';
          var str = "<".concat(pos, " style=\"").concat(posVal.style, "\">");
          if (posVal.color) str += "<color rgb=\"".concat(posVal.color, "\"/>");
          return str + "</".concat(pos, ">");
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          var str = '<border>';
          str += this._renderLine('left');
          str += this._renderLine('right');
          str += this._renderLine('top');
          str += this._renderLine('bottom');
          return str + '</border>';
        }
      }, {
        kind: "method",
        key: "equals",
        value: function equals(o) {
          var check = function check(a, b) {
            if (a && b) {
              return a.style === b.style && a.color === b.color;
            }

            return !a && !b;
          };

          return check(this.left, o.left) && check(this.right, o.right) && check(this.top, o.top) && check(this.bottom, o.bottom);
        }
      }]
    };
  }, Node);
  var XcellStyles = _decorate([props('count')], function (_initialize11, _Node21) {
    var XcellStyles =
    /*#__PURE__*/
    function (_Node22) {
      inherits(XcellStyles, _Node22);

      function XcellStyles() {
        var _getPrototypeOf11;

        var _this11;

        classCallCheck(this, XcellStyles);

        for (var _len10 = arguments.length, args = new Array(_len10), _key10 = 0; _key10 < _len10; _key10++) {
          args[_key10] = arguments[_key10];
        }

        _this11 = possibleConstructorReturn(this, (_getPrototypeOf11 = getPrototypeOf(XcellStyles)).call.apply(_getPrototypeOf11, [this].concat(args)));

        _initialize11(assertThisInitialized(_this11));

        return _this11;
      }

      return XcellStyles;
    }(_Node21);

    return {
      F: XcellStyles,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "cellStyles";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          if (this.count) return get(getPrototypeOf(XcellStyles.prototype), "render", this).call(this);
          return '';
        }
      }]
    };
  }, Node);
  var XcellStyle = _decorate([props('builtInId', 'customBuiltIn', 'hidden', 'iLevel', 'name', 'xfId')], function (_initialize12, _Node23) {
    var XcellStyle =
    /*#__PURE__*/
    function (_Node24) {
      inherits(XcellStyle, _Node24);

      function XcellStyle() {
        var _getPrototypeOf12;

        var _this12;

        classCallCheck(this, XcellStyle);

        for (var _len11 = arguments.length, args = new Array(_len11), _key11 = 0; _key11 < _len11; _key11++) {
          args[_key11] = arguments[_key11];
        }

        _this12 = possibleConstructorReturn(this, (_getPrototypeOf12 = getPrototypeOf(XcellStyle)).call.apply(_getPrototypeOf12, [this].concat(args)));

        _initialize12(assertThisInitialized(_this12));

        return _this12;
      }

      return XcellStyle;
    }(_Node23);

    return {
      F: XcellStyle,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "cellStyle";
        }
      }]
    };
  }, Node);
  var XcellStyleXfs = _decorate([props('count')], function (_initialize13, _Node25) {
    var XcellStyleXfs =
    /*#__PURE__*/
    function (_Node26) {
      inherits(XcellStyleXfs, _Node26);

      function XcellStyleXfs() {
        var _getPrototypeOf13;

        var _this13;

        classCallCheck(this, XcellStyleXfs);

        for (var _len12 = arguments.length, args = new Array(_len12), _key12 = 0; _key12 < _len12; _key12++) {
          args[_key12] = arguments[_key12];
        }

        _this13 = possibleConstructorReturn(this, (_getPrototypeOf13 = getPrototypeOf(XcellStyleXfs)).call.apply(_getPrototypeOf13, [this].concat(args)));

        _initialize13(assertThisInitialized(_this13));

        return _this13;
      }

      return XcellStyleXfs;
    }(_Node25);

    return {
      F: XcellStyleXfs,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "cellStyleXfs";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          if (this.count) return get(getPrototypeOf(XcellStyleXfs.prototype), "render", this).call(this);
          return '';
        }
      }]
    };
  }, Node);
  var XcellXfs = _decorate([props('count')], function (_initialize14, _Node27) {
    var XcellXfs =
    /*#__PURE__*/
    function (_Node28) {
      inherits(XcellXfs, _Node28);

      function XcellXfs() {
        var _getPrototypeOf14;

        var _this14;

        classCallCheck(this, XcellXfs);

        for (var _len13 = arguments.length, args = new Array(_len13), _key13 = 0; _key13 < _len13; _key13++) {
          args[_key13] = arguments[_key13];
        }

        _this14 = possibleConstructorReturn(this, (_getPrototypeOf14 = getPrototypeOf(XcellXfs)).call.apply(_getPrototypeOf14, [this].concat(args)));

        _initialize14(assertThisInitialized(_this14));

        return _this14;
      }

      return XcellXfs;
    }(_Node27);

    return {
      F: XcellXfs,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "cellXfs";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          if (this.count) return get(getPrototypeOf(XcellXfs.prototype), "render", this).call(this);
          return '';
        }
      }]
    };
  }, Node);
  var Xxf = _decorate([props('applyAlignment', 'applyBorder', 'applyFont', 'applyFill', 'applyNumberFormat', 'applyProtection', 'borderId', 'fillId', 'fontId', 'numFmtId', 'xfId')], function (_initialize15, _Node29) {
    var Xxf =
    /*#__PURE__*/
    function (_Node30) {
      inherits(Xxf, _Node30);

      function Xxf(attrs, children) {
        var _this15;

        classCallCheck(this, Xxf);

        var defaults = {
          applyAlignment: false,
          applyBorder: false,
          applyFont: false,
          applyFill: false,
          applyNumberFormat: false,
          applyProtection: false,
          borderId: 0,
          fillId: 0,
          fontId: 0,
          numFmtId: 0
        };
        _this15 = possibleConstructorReturn(this, getPrototypeOf(Xxf).call(this, objectSpread({}, defaults, attrs), children));

        _initialize15(assertThisInitialized(_this15));

        _this15.alignment = new Xalignment();
        return _this15;
      }

      return Xxf;
    }(_Node29);

    return {
      F: Xxf,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "xf";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          if (this.alignment) {
            this.children = [this.alignment];
          }

          return get(getPrototypeOf(Xxf.prototype), "render", this).call(this);
        }
      }, {
        kind: "method",
        key: "equals",
        value: function equals(o) {
          return this.applyAlignment === o.applyAlignment && this.applyBorder === o.applyBorder && this.applyFont === o.applyFont && this.applyFill === o.applyFill && this.applyProtection === o.applyProtection && this.borderId === o.borderId && this.fillId === o.fillId && this.fontId === o.fontId && this.numFmtId === o.numFmtId && this.xfId === o.xfId && this.alignment.equals(o.alignment);
        }
      }]
    };
  }, Node);
  var Xalignment = _decorate([props('horizontal', 'indent', 'shrinkToFit', 'textRotation', 'vertical', 'wrapText')], function (_initialize16, _Node31) {
    var Xalignment =
    /*#__PURE__*/
    function (_Node32) {
      inherits(Xalignment, _Node32);

      function Xalignment(attrs) {
        var _this16;

        var children = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];

        classCallCheck(this, Xalignment);

        var defaults = {
          horizontal: 'general',
          indent: 0,
          shrinkToFit: false,
          textRotation: 0,
          vertical: 'bottom',
          wrapText: false
        };
        _this16 = possibleConstructorReturn(this, getPrototypeOf(Xalignment).call(this, objectSpread({}, defaults, attrs), children));

        _initialize16(assertThisInitialized(_this16));

        return _this16;
      }

      return Xalignment;
    }(_Node31);

    return {
      F: Xalignment,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "alignment";
        }
      }, {
        kind: "method",
        key: "equals",
        value: function equals(o) {
          return this.horizontal === o.horizontal && this.indent === o.indent && this.shrinkToFit === o.shrinkToFit && this.textRotation === o.textRotation && this.vertical === o.vertical && this.wrapText === o.wrapText;
        }
      }]
    };
  }, Node);

  function handleStyle(style, numFmtId, styles) {
    var _style$makeXStyleElem = style.makeXStyleElements(),
        xFont = _style$makeXStyleElem.xFont,
        xFill = _style$makeXStyleElem.xFill,
        xBorder = _style$makeXStyleElem.xBorder,
        xXf = _style$makeXStyleElem.xXf;

    var fontId = styles.addFont(xFont);
    var fillId = styles.addFill(xFill); // HACK - adding light grey fill, as in OO and Google

    var greyfill = new Xfill({
      patternFill: new XpatternFill({
        patternType: 'lightGray'
      })
    });
    styles.addFill(greyfill);
    var borderId = styles.addBorder(xBorder);
    xXf.fontId = fontId;
    xXf.fillId = fillId;
    xXf.borderId = borderId;
    xXf.numFmtId = numFmtId; // apply the numFmtId when it is not the default cellxf

    if (xXf.numFmtId > 0) {
      xXf.applyNumberFormat = true;
    }

    xXf.alignment.horizontal = style.align.h;
    xXf.alignment.indent = style.align.indent;
    xXf.alignment.shrinkToFit = style.align.shrinkToFit;
    xXf.alignment.textRotation = style.align.textRotation;
    xXf.alignment.vertical = style.align.v;
    xXf.alignment.wrapText = style.align.wrapText;
    return styles.addCellXf(xXf);
  }
  function handleNumFmtId(numFmtId, styles) {
    var xf = new Xxf({
      numFmtId: numFmtId
    });

    if (numFmtId > 0) {
      xf.applyNumberFormat = true;
    }

    return styles.addCellXf(xf);
  }
  /**
   * Style class for set Cell styles.
   */

  var Style =
  /*#__PURE__*/
  function () {
    function Style() {
      classCallCheck(this, Style);

      defineProperty(this, "applyBorder", false);

      defineProperty(this, "applyFill", false);

      defineProperty(this, "applyFont", false);

      defineProperty(this, "applyAlignment", false);

      defineProperty(this, "namedStyleIndex", null);

      /**
       * Cell border
       * @type {Border}
       */
      this.border = new Border({});
      /**
       * Cell fill background or foreground
       * @type {Fill}
       */

      this.fill = new Fill({});
      /**
       * Cell font
       * @type {Font}
       */

      this.font = new Font({});
      /**
       * Cell alignment
       * @type {Alignment}
       */

      this.align = new Alignment({});
    }

    createClass(Style, [{
      key: "makeXStyleElements",
      value: function makeXStyleElements() {
        var xFont = new Xfont({
          sz: this.font.size,
          name: this.font.name,
          family: this.font.family,
          charset: this.font.charset,
          color: this.font.color,
          b: this.font.bold,
          i: this.font.italic,
          u: this.font.underline
        });
        var xFill = new Xfill({
          patternFill: new XpatternFill({
            patternType: this.fill.patternType,
            fgColor: this.fill.fgColor,
            bgColor: this.fill.bgColor
          })
        });
        var xBorder = new Xborder({
          left: {
            style: this.border.left,
            color: this.border.leftColor
          },
          right: {
            style: this.border.right,
            color: this.border.rightColor
          },
          top: {
            style: this.border.top,
            color: this.border.topColor
          },
          bottom: {
            style: this.border.bottom,
            color: this.border.bottomColor
          }
        });
        var xXf = new Xxf({
          numFmtId: 0,
          applyBorder: this.applyBorder,
          applyFill: this.applyFill,
          applyFont: this.applyFont,
          applyAlignment: this.applyAlignment
        });
        xXf.alignment = new Xalignment({
          horizontal: this.align.h,
          indent: this.align.indent,
          shrinkToFit: this.align.shrinkToFit,
          textRotation: this.align.textRotation,
          vertical: this.align.v,
          wrapText: this.align.wrapText
        });

        if (this.namedStyleIndex !== null) {
          xXf.xfId = this.namedStyleIndex;
        }

        return {
          xFont: xFont,
          xFill: xFill,
          xBorder: xBorder,
          xXf: xXf
        };
      }
    }]);

    return Style;
  }();
  /**
   * Border of the Style and border type have: `none`, `thin`, `medium`, `thick`, `dashed`, `dotted`, `double`
   *
   */

  var Border =
  /**
   * left border color
   * @type {String}
   */

  /**
   * right border color
   * @type {String}
   */

  /**
   * top border color
   * @type {String}
   */

  /**
   * bottom border color
   * @type {String}
   */
  function Border(_ref) {
    var _ref$left = _ref.left,
        left = _ref$left === void 0 ? 'none' : _ref$left,
        _ref$right = _ref.right,
        right = _ref$right === void 0 ? 'none' : _ref$right,
        _ref$top = _ref.top,
        top = _ref$top === void 0 ? 'none' : _ref$top,
        _ref$bottom = _ref.bottom,
        bottom = _ref$bottom === void 0 ? 'none' : _ref$bottom;

    classCallCheck(this, Border);

    defineProperty(this, "leftColor", undefined);

    defineProperty(this, "rightColor", undefined);

    defineProperty(this, "topColor", undefined);

    defineProperty(this, "bottomColor", undefined);

    /**
     * left border type
     * @type {String}
     */
    this.left = left;
    /**
     * right border type
     * @type {String}
     */

    this.right = right;
    /**
     * top border type
     * @type {String}
     */

    this.top = top;
    /**
     * bottom border type
     * @type {String}
     */

    this.bottom = bottom;
  };
  /**
   * Fill of the Style
   */

  var Fill = function Fill(_ref2) {
    var _ref2$patternType = _ref2.patternType,
        patternType = _ref2$patternType === void 0 ? 'none' : _ref2$patternType,
        _ref2$fgColor = _ref2.fgColor,
        fgColor = _ref2$fgColor === void 0 ? 'FFFFFFFF' : _ref2$fgColor,
        _ref2$bgColor = _ref2.bgColor,
        bgColor = _ref2$bgColor === void 0 ? '00000000' : _ref2$bgColor;

    classCallCheck(this, Fill);

    /**
     * pattern type of the fill
     * @type {String}
     */
    this.patternType = patternType;
    /**
     * foreground color of the fill
     * @type {String}
     */

    this.fgColor = fgColor;
    /**
     * background color of the fill
     * @type {String}
     */

    this.bgColor = bgColor;
  };
  /**
   * Font of the Style
   */

  var Font =
  /**
   * font color
   * @type {String}
   */

  /**
   * Is bold style
   * @type {Boolean}
   */

  /**
   * Is italic style
   * @type {Boolean}
   */

  /**
   * IS underline style
   * @type {Boolean}
   */
  function Font(_ref3) {
    var _ref3$size = _ref3.size,
        size = _ref3$size === void 0 ? 12 : _ref3$size,
        _ref3$name = _ref3.name,
        name = _ref3$name === void 0 ? 'Verdana' : _ref3$name;

    classCallCheck(this, Font);

    defineProperty(this, "family", 0);

    defineProperty(this, "charset", 0);

    defineProperty(this, "color", undefined);

    defineProperty(this, "bold", false);

    defineProperty(this, "italic", false);

    defineProperty(this, "underline", false);

    /**
     * font size [default 12]
     * @type {Number}
     */
    this.size = size;
    this.name = name;
  };
  /**
   * Alignment of the Style.
   */

  var Alignment = function Alignment(_ref4) {
    var _ref4$h = _ref4.h,
        h = _ref4$h === void 0 ? 'general' : _ref4$h,
        _ref4$v = _ref4.v,
        v = _ref4$v === void 0 ? 'bottom' : _ref4$v;

    classCallCheck(this, Alignment);

    defineProperty(this, "indent", 0);

    defineProperty(this, "shrinkToFit", false);

    defineProperty(this, "textRotation", 0);

    defineProperty(this, "wrapText", false);

    /**
     * Horizontal align: `general`, `center`, `left`, `right`
     * @type {String}
     */
    this.h = h;
    /**
     * Vertical align: `general`, `top`, `bottom`, `center`
     * @type {String}
     */

    this.v = v;
  };

  var style = /*#__PURE__*/Object.freeze({
    handleStyle: handleStyle,
    handleNumFmtId: handleNumFmtId,
    Style: Style,
    Border: Border,
    Fill: Fill,
    Font: Font,
    Alignment: Alignment
  });

  var toString = Object.prototype.toString;

  var kindOf = function kindOf(val) {
    if (val === void 0) return 'undefined';
    if (val === null) return 'null';

    var type = typeof val;
    if (type === 'boolean') return 'boolean';
    if (type === 'string') return 'string';
    if (type === 'number') return 'number';
    if (type === 'symbol') return 'symbol';
    if (type === 'function') {
      return isGeneratorFn(val) ? 'generatorfunction' : 'function';
    }

    if (isArray(val)) return 'array';
    if (isBuffer(val)) return 'buffer';
    if (isArguments(val)) return 'arguments';
    if (isDate(val)) return 'date';
    if (isError(val)) return 'error';
    if (isRegexp(val)) return 'regexp';

    switch (ctorName(val)) {
      case 'Symbol': return 'symbol';
      case 'Promise': return 'promise';

      // Set, Map, WeakSet, WeakMap
      case 'WeakMap': return 'weakmap';
      case 'WeakSet': return 'weakset';
      case 'Map': return 'map';
      case 'Set': return 'set';

      // 8-bit typed arrays
      case 'Int8Array': return 'int8array';
      case 'Uint8Array': return 'uint8array';
      case 'Uint8ClampedArray': return 'uint8clampedarray';

      // 16-bit typed arrays
      case 'Int16Array': return 'int16array';
      case 'Uint16Array': return 'uint16array';

      // 32-bit typed arrays
      case 'Int32Array': return 'int32array';
      case 'Uint32Array': return 'uint32array';
      case 'Float32Array': return 'float32array';
      case 'Float64Array': return 'float64array';
    }

    if (isGeneratorObj(val)) {
      return 'generator';
    }

    // Non-plain objects
    type = toString.call(val);
    switch (type) {
      case '[object Object]': return 'object';
      // iterators
      case '[object Map Iterator]': return 'mapiterator';
      case '[object Set Iterator]': return 'setiterator';
      case '[object String Iterator]': return 'stringiterator';
      case '[object Array Iterator]': return 'arrayiterator';
    }

    // other
    return type.slice(8, -1).toLowerCase().replace(/\s/g, '');
  };

  function ctorName(val) {
    return val.constructor ? val.constructor.name : null;
  }

  function isArray(val) {
    if (Array.isArray) return Array.isArray(val);
    return val instanceof Array;
  }

  function isError(val) {
    return val instanceof Error || (typeof val.message === 'string' && val.constructor && typeof val.constructor.stackTraceLimit === 'number');
  }

  function isDate(val) {
    if (val instanceof Date) return true;
    return typeof val.toDateString === 'function'
      && typeof val.getDate === 'function'
      && typeof val.setDate === 'function';
  }

  function isRegexp(val) {
    if (val instanceof RegExp) return true;
    return typeof val.flags === 'string'
      && typeof val.ignoreCase === 'boolean'
      && typeof val.multiline === 'boolean'
      && typeof val.global === 'boolean';
  }

  function isGeneratorFn(name, val) {
    return ctorName(name) === 'GeneratorFunction';
  }

  function isGeneratorObj(val) {
    return typeof val.throw === 'function'
      && typeof val.return === 'function'
      && typeof val.next === 'function';
  }

  function isArguments(val) {
    try {
      if (typeof val.length === 'number' && typeof val.callee === 'function') {
        return true;
      }
    } catch (err) {
      if (err.message.indexOf('callee') !== -1) {
        return true;
      }
    }
    return false;
  }

  /**
   * If you need to support Safari 5-7 (8-10 yr-old browser),
   * take a look at https://github.com/feross/is-buffer
   */

  function isBuffer(val) {
    if (val.constructor && typeof val.constructor.isBuffer === 'function') {
      return val.constructor.isBuffer(val);
    }
    return false;
  }

  var CellType = {
    TypeString: 49,
    TypeFormula: 0,
    TypeNumeric: 1,
    TypeBool: 0,
    TypeInline: 0,
    TypeError: 0,
    TypeDate: 14,
    TypeGeneral: 0
  };
  /**
   * Cell intended to provide user access to the contents of Cell within an xlsx.Row.
   *
   * ```js
   * const cell = row.addCell();
   * cell.value = 'I am a cell!';
   * cell.hMerge = 2;
   * cell.vMerge = 1;
   * cell.style.fill.patternType = 'solid';
   * cell.style.fill.fgColor = '00FF0000';
   * cell.style.fill.bgColor = 'FF000000';
   * cell.style.align.h = 'center';
   * cell.style.align.v = 'center';
   * ```
   *
   * Set the cell value
   *
   * ```js
   * const cell = row.addCell();
   * // Date type
   * cell.setDate(new Date());
   * // Number type
   * cell.setNumber(123456);
   * cell.numFmt = '$#,##0.00';
   * ```
   */

  var Cell =
  /*#__PURE__*/
  function () {
    /**
     * Number format @see {@link NumFmt}
     * @type {String}
     */

    /**
     * Hide the cell.
     * @type {Boolean}
     */

    /**
     * Horizontal merge with other cells.
     * @type {Number}
     */

    /**
     * Vertical merge with other cells.
     * @type {Number}
     */

    /**
     * Create a cell and add it to a row.
     * @private
     * @param  {Object} options.row Row of add to
     */
    function Cell(_ref) {
      var row = _ref.row;

      classCallCheck(this, Cell);

      defineProperty(this, "_value", '');

      defineProperty(this, "_style", null);

      defineProperty(this, "formula", '');

      defineProperty(this, "numFmt", '');

      defineProperty(this, "date1904", false);

      defineProperty(this, "hidden", false);

      defineProperty(this, "hMerge", 0);

      defineProperty(this, "vMerge", 0);

      defineProperty(this, "cellType", 'TypeString');

      this.row = row;
    }
    /**
     * Get the cell style.
     * @return {Style}
     */


    createClass(Cell, [{
      key: "setString",

      /**
       * Set cell value with String type.
       * @param {String} v
       */
      value: function setString(v) {
        this._value = v;
        this.formula = '';
        this.cellType = 'TypeString';
      }
      /**
       * Set cell value with Date type.
       * @param {Date} v
       */

    }, {
      key: "setDate",
      value: function setDate(v) {
        this._value = parseInt(toExcelTime(v));
        this.formula = '';
        this.numFmt = NumFmt[14];
        this.cellType = 'TypeDate';
      }
      /**
       * Set cell value with DateTime type.
       * @param {Date} v
       */

    }, {
      key: "setDateTime",
      value: function setDateTime(v) {
        this._value = toExcelTime(v);
        this.formula = '';
        this.numFmt = NumFmt[22];
        this.cellType = 'TypeDate';
      }
      /**
       * Set cell value with Number type.
       * @param {Number} v
       */

    }, {
      key: "setNumber",
      value: function setNumber(v) {
        this._value = v;
        this.formula = '';
        this.numFmt = NumFmt[0];
        this.cellType = 'TypeNumeric';
      }
      /**
       * Set cell value with Boolean type.
       * @param {Boolean} v
       */

    }, {
      key: "setBool",
      value: function setBool(v) {
        this._value = v ? 1 : 0;
        this.cellType = 'TypeBool';
      }
      /**
       * Set cell formula.
       * @param {String} f - Formula like `B2*C2-D2`.
       */

    }, {
      key: "setFormula",
      value: function setFormula(f) {
        this.formula = f;
        this.cellType = 'TypeFormula';
      }
    }, {
      key: "style",
      get: function get() {
        if (this._style === null) {
          this._style = new Style();
        }

        return this._style;
      }
      /**
       * Set the style of the cell.
       * @param  {Style} s
       */
      ,
      set: function set(s) {
        this._style = s;
      }
      /**
       * Get the cell value.
       */

    }, {
      key: "value",
      get: function get() {
        return this._value;
      }
      /**
       * Set the cell value.
       * @param  {String|Date|Number|Boolean} v
       */
      ,
      set: function set(v) {
        var t = kindOf(v);

        if (t === 'null' || t === 'undefined') {
          return this.setString('');
        }

        if (t === 'date') {
          return this.setDateTime(v);
        }

        if (t === 'number') {
          return this.setNumber(v);
        }

        if (t === 'string') {
          return this.setString(v);
        }

        if (t === 'boolean') {
          return this.setBool(v);
        }

        return this.setString(v.toString());
      }
    }]);

    return Cell;
  }();

  var cell = /*#__PURE__*/Object.freeze({
    CellType: CellType,
    Cell: Cell
  });

  /**
   * The column of the Sheet.
   *
   * ```js
   * const col = sheet.col(0);
   * col.width = 20;
   * col.style.fill.patternType = 'solid';
   * col.style.fill.fgColor = '00FF0000';
   * col.style.fill.bgColor = 'FF000000';
   * col.style.align.h = 'center';
   * col.style.align.v = 'center';
   * ```
   */

  var Col =
  /*#__PURE__*/
  function () {
    /**
     * Number format for all column @see {@link NumFmt}
     * @type {String}
     */
    function Col(_ref) {
      var min = _ref.min,
          max = _ref.max,
          _ref$hidden = _ref.hidden,
          hidden = _ref$hidden === void 0 ? false : _ref$hidden,
          _ref$collapsed = _ref.collapsed,
          collapsed = _ref$collapsed === void 0 ? false : _ref$collapsed,
          _ref$width = _ref.width,
          width = _ref$width === void 0 ? 0 : _ref$width;

      classCallCheck(this, Col);

      defineProperty(this, "outlineLevel", 0);

      defineProperty(this, "numFmt", '');

      this.min = min;
      this.max = max;
      this.hidden = hidden;
      this.collapsed = collapsed;
      /**
       * Column width [default 9.5]
       * @type {Number}
       */

      this.width = width;
      /**
       * Style of the column.
       * @type {Style}
       */

      this.style = new Style();
    }

    createClass(Col, [{
      key: "setType",
      value: function setType(cellType) {
        this.numFmt = NumFmt[cellType];
      }
    }]);

    return Col;
  }();

  var col = /*#__PURE__*/Object.freeze({
    Col: Col
  });

  /**
   * Row of the sheet.
   * ```js
   * const row = sheet.addRow();
   * row.setHeightCM(0.8);
   * ```
   */

  var Row =
  /*#__PURE__*/
  function () {
    /**
     * Row height
     * @type {Number}
     */
    function Row(_ref) {
      var sheet = _ref.sheet;

      classCallCheck(this, Row);

      defineProperty(this, "cells", []);

      defineProperty(this, "hidden", false);

      defineProperty(this, "height", 0);

      defineProperty(this, "outlineLevel", 0);

      defineProperty(this, "isCustom", false);

      this.sheet = sheet;
    }
    /**
     * Set height of the Row with `cm` unit.
     * @param {Number} ht Height with `cm` unit
     */


    createClass(Row, [{
      key: "setHeightCM",
      value: function setHeightCM(ht) {
        this.height = ht * 28.3464567;
        this.isCustom = true;
      }
      /**
       * Create a cell and add it into the Row.
       * @return {Cell}
       */

    }, {
      key: "addCell",
      value: function addCell() {
        var cell = new Cell({
          row: this
        });
        this.cells.push(cell);
        this.sheet.maybeAddCol(this.cells.length);
        return cell;
      }
    }]);

    return Row;
  }();

  var row = /*#__PURE__*/Object.freeze({
    Row: Row
  });

  function _decorate$1(decorators, factory, superClass, mixins) { var api = _getDecoratorsApi$1(); if (mixins) { for (var i = 0; i < mixins.length; i++) { api = mixins[i](api); } } var r = factory(function initialize(O) { api.initializeInstanceElements(O, decorated.elements); }, superClass); var decorated = api.decorateClass(_coalesceClassElements$1(r.d.map(_createElementDescriptor$1)), decorators); api.initializeClassElements(r.F, decorated.elements); return api.runClassFinishers(r.F, decorated.finishers); }

  function _getDecoratorsApi$1() { _getDecoratorsApi$1 = function _getDecoratorsApi() { return api; }; var api = { elementsDefinitionOrder: [["method"], ["field"]], initializeInstanceElements: function initializeInstanceElements(O, elements) { ["method", "field"].forEach(function (kind) { elements.forEach(function (element) { if (element.kind === kind && element.placement === "own") { this.defineClassElement(O, element); } }, this); }, this); }, initializeClassElements: function initializeClassElements(F, elements) { var proto = F.prototype; ["method", "field"].forEach(function (kind) { elements.forEach(function (element) { var placement = element.placement; if (element.kind === kind && (placement === "static" || placement === "prototype")) { var receiver = placement === "static" ? F : proto; this.defineClassElement(receiver, element); } }, this); }, this); }, defineClassElement: function defineClassElement(receiver, element) { var descriptor = element.descriptor; if (element.kind === "field") { var initializer = element.initializer; descriptor = { enumerable: descriptor.enumerable, writable: descriptor.writable, configurable: descriptor.configurable, value: initializer === void 0 ? void 0 : initializer.call(receiver) }; } Object.defineProperty(receiver, element.key, descriptor); }, decorateClass: function decorateClass(elements, decorators) { var newElements = []; var finishers = []; var placements = { "static": [], prototype: [], own: [] }; elements.forEach(function (element) { this.addElementPlacement(element, placements); }, this); elements.forEach(function (element) { if (!_hasDecorators$1(element)) return newElements.push(element); var elementFinishersExtras = this.decorateElement(element, placements); newElements.push(elementFinishersExtras.element); newElements.push.apply(newElements, elementFinishersExtras.extras); finishers.push.apply(finishers, elementFinishersExtras.finishers); }, this); if (!decorators) { return { elements: newElements, finishers: finishers }; } var result = this.decorateConstructor(newElements, decorators); finishers.push.apply(finishers, result.finishers); result.finishers = finishers; return result; }, addElementPlacement: function addElementPlacement(element, placements, silent) { var keys = placements[element.placement]; if (!silent && keys.indexOf(element.key) !== -1) { throw new TypeError("Duplicated element (" + element.key + ")"); } keys.push(element.key); }, decorateElement: function decorateElement(element, placements) { var extras = []; var finishers = []; for (var decorators = element.decorators, i = decorators.length - 1; i >= 0; i--) { var keys = placements[element.placement]; keys.splice(keys.indexOf(element.key), 1); var elementObject = this.fromElementDescriptor(element); var elementFinisherExtras = this.toElementFinisherExtras((0, decorators[i])(elementObject) || elementObject); element = elementFinisherExtras.element; this.addElementPlacement(element, placements); if (elementFinisherExtras.finisher) { finishers.push(elementFinisherExtras.finisher); } var newExtras = elementFinisherExtras.extras; if (newExtras) { for (var j = 0; j < newExtras.length; j++) { this.addElementPlacement(newExtras[j], placements); } extras.push.apply(extras, newExtras); } } return { element: element, finishers: finishers, extras: extras }; }, decorateConstructor: function decorateConstructor(elements, decorators) { var finishers = []; for (var i = decorators.length - 1; i >= 0; i--) { var obj = this.fromClassDescriptor(elements); var elementsAndFinisher = this.toClassDescriptor((0, decorators[i])(obj) || obj); if (elementsAndFinisher.finisher !== undefined) { finishers.push(elementsAndFinisher.finisher); } if (elementsAndFinisher.elements !== undefined) { elements = elementsAndFinisher.elements; for (var j = 0; j < elements.length - 1; j++) { for (var k = j + 1; k < elements.length; k++) { if (elements[j].key === elements[k].key && elements[j].placement === elements[k].placement) { throw new TypeError("Duplicated element (" + elements[j].key + ")"); } } } } } return { elements: elements, finishers: finishers }; }, fromElementDescriptor: function fromElementDescriptor(element) { var obj = { kind: element.kind, key: element.key, placement: element.placement, descriptor: element.descriptor }; var desc = { value: "Descriptor", configurable: true }; Object.defineProperty(obj, Symbol.toStringTag, desc); if (element.kind === "field") obj.initializer = element.initializer; return obj; }, toElementDescriptors: function toElementDescriptors(elementObjects) { if (elementObjects === undefined) return; return toArray(elementObjects).map(function (elementObject) { var element = this.toElementDescriptor(elementObject); this.disallowProperty(elementObject, "finisher", "An element descriptor"); this.disallowProperty(elementObject, "extras", "An element descriptor"); return element; }, this); }, toElementDescriptor: function toElementDescriptor(elementObject) { var kind = String(elementObject.kind); if (kind !== "method" && kind !== "field") { throw new TypeError('An element descriptor\'s .kind property must be either "method" or' + ' "field", but a decorator created an element descriptor with' + ' .kind "' + kind + '"'); } var key = _toPropertyKey$1(elementObject.key); var placement = String(elementObject.placement); if (placement !== "static" && placement !== "prototype" && placement !== "own") { throw new TypeError('An element descriptor\'s .placement property must be one of "static",' + ' "prototype" or "own", but a decorator created an element descriptor' + ' with .placement "' + placement + '"'); } var descriptor = elementObject.descriptor; this.disallowProperty(elementObject, "elements", "An element descriptor"); var element = { kind: kind, key: key, placement: placement, descriptor: Object.assign({}, descriptor) }; if (kind !== "field") { this.disallowProperty(elementObject, "initializer", "A method descriptor"); } else { this.disallowProperty(descriptor, "get", "The property descriptor of a field descriptor"); this.disallowProperty(descriptor, "set", "The property descriptor of a field descriptor"); this.disallowProperty(descriptor, "value", "The property descriptor of a field descriptor"); element.initializer = elementObject.initializer; } return element; }, toElementFinisherExtras: function toElementFinisherExtras(elementObject) { var element = this.toElementDescriptor(elementObject); var finisher = _optionalCallableProperty$1(elementObject, "finisher"); var extras = this.toElementDescriptors(elementObject.extras); return { element: element, finisher: finisher, extras: extras }; }, fromClassDescriptor: function fromClassDescriptor(elements) { var obj = { kind: "class", elements: elements.map(this.fromElementDescriptor, this) }; var desc = { value: "Descriptor", configurable: true }; Object.defineProperty(obj, Symbol.toStringTag, desc); return obj; }, toClassDescriptor: function toClassDescriptor(obj) { var kind = String(obj.kind); if (kind !== "class") { throw new TypeError('A class descriptor\'s .kind property must be "class", but a decorator' + ' created a class descriptor with .kind "' + kind + '"'); } this.disallowProperty(obj, "key", "A class descriptor"); this.disallowProperty(obj, "placement", "A class descriptor"); this.disallowProperty(obj, "descriptor", "A class descriptor"); this.disallowProperty(obj, "initializer", "A class descriptor"); this.disallowProperty(obj, "extras", "A class descriptor"); var finisher = _optionalCallableProperty$1(obj, "finisher"); var elements = this.toElementDescriptors(obj.elements); return { elements: elements, finisher: finisher }; }, runClassFinishers: function runClassFinishers(constructor, finishers) { for (var i = 0; i < finishers.length; i++) { var newConstructor = (0, finishers[i])(constructor); if (newConstructor !== undefined) { if (typeof newConstructor !== "function") { throw new TypeError("Finishers must return a constructor."); } constructor = newConstructor; } } return constructor; }, disallowProperty: function disallowProperty(obj, name, objectType) { if (obj[name] !== undefined) { throw new TypeError(objectType + " can't have a ." + name + " property."); } } }; return api; }

  function _createElementDescriptor$1(def) { var key = _toPropertyKey$1(def.key); var descriptor; if (def.kind === "method") { descriptor = { value: def.value, writable: true, configurable: true, enumerable: false }; } else if (def.kind === "get") { descriptor = { get: def.value, configurable: true, enumerable: false }; } else if (def.kind === "set") { descriptor = { set: def.value, configurable: true, enumerable: false }; } else if (def.kind === "field") { descriptor = { configurable: true, writable: true, enumerable: true }; } var element = { kind: def.kind === "field" ? "field" : "method", key: key, placement: def["static"] ? "static" : def.kind === "field" ? "own" : "prototype", descriptor: descriptor }; if (def.decorators) element.decorators = def.decorators; if (def.kind === "field") element.initializer = def.value; return element; }

  function _coalesceGetterSetter$1(element, other) { if (element.descriptor.get !== undefined) { other.descriptor.get = element.descriptor.get; } else { other.descriptor.set = element.descriptor.set; } }

  function _coalesceClassElements$1(elements) { var newElements = []; var isSameElement = function isSameElement(other) { return other.kind === "method" && other.key === element.key && other.placement === element.placement; }; for (var i = 0; i < elements.length; i++) { var element = elements[i]; var other; if (element.kind === "method" && (other = newElements.find(isSameElement))) { if (_isDataDescriptor$1(element.descriptor) || _isDataDescriptor$1(other.descriptor)) { if (_hasDecorators$1(element) || _hasDecorators$1(other)) { throw new ReferenceError("Duplicated methods (" + element.key + ") can't be decorated."); } other.descriptor = element.descriptor; } else { if (_hasDecorators$1(element)) { if (_hasDecorators$1(other)) { throw new ReferenceError("Decorators can't be placed on different accessors with for " + "the same property (" + element.key + ")."); } other.decorators = element.decorators; } _coalesceGetterSetter$1(element, other); } } else { newElements.push(element); } } return newElements; }

  function _hasDecorators$1(element) { return element.decorators && element.decorators.length; }

  function _isDataDescriptor$1(desc) { return desc !== undefined && !(desc.value === undefined && desc.writable === undefined); }

  function _optionalCallableProperty$1(obj, name) { var value = obj[name]; if (value !== undefined && typeof value !== "function") { throw new TypeError("Expected '" + name + "' to be a function"); } return value; }

  function _toPropertyKey$1(arg) { var key = _toPrimitive$1(arg, "string"); return _typeof_1(key) === "symbol" ? key : String(key); }

  function _toPrimitive$1(input, hint) { if (_typeof_1(input) !== "object" || input === null) return input; var prim = input[Symbol.toPrimitive]; if (prim !== undefined) { var res = prim.call(input, hint || "default"); if (_typeof_1(res) !== "object") return res; throw new TypeError("@@toPrimitive must return a primitive value."); } return (hint === "string" ? String : Number)(input); }
  var Xworksheet = _decorate$1([props('xmlns', 'xmlns:r')], function (_initialize, _Node) {
    var Xworksheet =
    /*#__PURE__*/
    function (_Node2) {
      inherits(Xworksheet, _Node2);

      function Xworksheet() {
        var _this;

        var attrs = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
        var children = arguments.length > 1 ? arguments[1] : undefined;

        classCallCheck(this, Xworksheet);

        attrs['xmlns'] = attrs['xmlns'] || 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
        attrs['xmlns:r'] = attrs['xmlns:r'] || 'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
        _this = possibleConstructorReturn(this, getPrototypeOf(Xworksheet).call(this, attrs, children));

        _initialize(assertThisInitialized(_this));

        _this[HEAD] = '<?xml version="1.0" encoding="UTF-8"?>';
        return _this;
      }

      return Xworksheet;
    }(_Node);

    return {
      F: Xworksheet,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "worksheet";
        }
      }, {
        kind: "field",
        key: "sheetPr",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "sheetViews",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "sheetFormatPr",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "printOptions",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "pageMargins",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "pageSetup",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "headerFooter",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "mergeCells",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "dimension",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "cols",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "sheetData",
        value: function value() {
          return null;
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          this.children = [];
          if (this.sheetPr) this.children.push(this.sheetPr);
          if (this.dimension) this.children.push(this.dimension);
          if (this.sheetViews) this.children.push(this.sheetViews);
          if (this.sheetFormatPr) this.children.push(this.sheetFormatPr);
          if (this.cols) this.children.push(this.cols);
          if (this.sheetData) this.children.push(this.sheetData);
          if (this.mergeCells) this.children.push(this.mergeCells);
          if (this.printOptions) this.children.push(this.printOptions);
          if (this.pageMargins) this.children.push(this.pageMargins);
          if (this.pageSetup) this.children.push(this.pageSetup);
          if (this.headerFooter) this.children.push(this.headerFooter);
          return get(getPrototypeOf(Xworksheet.prototype), "render", this).call(this);
        }
      }]
    };
  }, Node);
  var XsheetPr = _decorate$1([props('filterMode')], function (_initialize2, _Node3) {
    var XsheetPr =
    /*#__PURE__*/
    function (_Node4) {
      inherits(XsheetPr, _Node4);

      function XsheetPr() {
        var _getPrototypeOf2;

        var _this2;

        classCallCheck(this, XsheetPr);

        for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
          args[_key] = arguments[_key];
        }

        _this2 = possibleConstructorReturn(this, (_getPrototypeOf2 = getPrototypeOf(XsheetPr)).call.apply(_getPrototypeOf2, [this].concat(args)));

        _initialize2(assertThisInitialized(_this2));

        return _this2;
      }

      return XsheetPr;
    }(_Node3);

    return {
      F: XsheetPr,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "sheetPr";
        }
      }]
    };
  }, Node);
  var XpageSetUpPr = _decorate$1([props('fitToPage')], function (_initialize3, _Node5) {
    var XpageSetUpPr =
    /*#__PURE__*/
    function (_Node6) {
      inherits(XpageSetUpPr, _Node6);

      function XpageSetUpPr() {
        var _getPrototypeOf3;

        var _this3;

        classCallCheck(this, XpageSetUpPr);

        for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
          args[_key2] = arguments[_key2];
        }

        _this3 = possibleConstructorReturn(this, (_getPrototypeOf3 = getPrototypeOf(XpageSetUpPr)).call.apply(_getPrototypeOf3, [this].concat(args)));

        _initialize3(assertThisInitialized(_this3));

        return _this3;
      }

      return XpageSetUpPr;
    }(_Node5);

    return {
      F: XpageSetUpPr,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "pageSetUpPr";
        }
      }]
    };
  }, Node);
  var Xdimension = _decorate$1([props('ref')], function (_initialize4, _Node7) {
    var Xdimension =
    /*#__PURE__*/
    function (_Node8) {
      inherits(Xdimension, _Node8);

      function Xdimension() {
        var _getPrototypeOf4;

        var _this4;

        classCallCheck(this, Xdimension);

        for (var _len3 = arguments.length, args = new Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
          args[_key3] = arguments[_key3];
        }

        _this4 = possibleConstructorReturn(this, (_getPrototypeOf4 = getPrototypeOf(Xdimension)).call.apply(_getPrototypeOf4, [this].concat(args)));

        _initialize4(assertThisInitialized(_this4));

        return _this4;
      }

      return Xdimension;
    }(_Node7);

    return {
      F: Xdimension,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "dimension";
        }
      }]
    };
  }, Node);
  var XsheetViews =
  /*#__PURE__*/
  function (_Node9) {
    inherits(XsheetViews, _Node9);

    function XsheetViews() {
      var _getPrototypeOf5;

      var _this5;

      classCallCheck(this, XsheetViews);

      for (var _len4 = arguments.length, args = new Array(_len4), _key4 = 0; _key4 < _len4; _key4++) {
        args[_key4] = arguments[_key4];
      }

      _this5 = possibleConstructorReturn(this, (_getPrototypeOf5 = getPrototypeOf(XsheetViews)).call.apply(_getPrototypeOf5, [this].concat(args)));

      defineProperty(assertThisInitialized(_this5), "__name", "sheetViews");

      return _this5;
    }

    return XsheetViews;
  }(Node);
  var XsheetView = _decorate$1([props('windowProtection', 'showFormulas', 'showGridLines', 'showRowColHeaders', 'showZeros', 'rightToLeft', 'tabSelected', 'showOutlineSymbols', 'defaultGridColor', 'view', 'topLeftCell', 'colorId', 'zoomScale', 'zoomScaleNormal', 'zoomScalePageLayoutView', 'workbookViewId')], function (_initialize5, _Node10) {
    var XsheetView =
    /*#__PURE__*/
    function (_Node11) {
      inherits(XsheetView, _Node11);

      function XsheetView() {
        var _getPrototypeOf6;

        var _this6;

        classCallCheck(this, XsheetView);

        for (var _len5 = arguments.length, args = new Array(_len5), _key5 = 0; _key5 < _len5; _key5++) {
          args[_key5] = arguments[_key5];
        }

        _this6 = possibleConstructorReturn(this, (_getPrototypeOf6 = getPrototypeOf(XsheetView)).call.apply(_getPrototypeOf6, [this].concat(args)));

        _initialize5(assertThisInitialized(_this6));

        return _this6;
      }

      return XsheetView;
    }(_Node10);

    return {
      F: XsheetView,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "sheetView";
        }
      }]
    };
  }, Node);
  var Xselection = _decorate$1([props('pane', 'activeCell', 'activeCellId', 'sqref')], function (_initialize6, _Node12) {
    var Xselection =
    /*#__PURE__*/
    function (_Node13) {
      inherits(Xselection, _Node13);

      function Xselection() {
        var _getPrototypeOf7;

        var _this7;

        classCallCheck(this, Xselection);

        for (var _len6 = arguments.length, args = new Array(_len6), _key6 = 0; _key6 < _len6; _key6++) {
          args[_key6] = arguments[_key6];
        }

        _this7 = possibleConstructorReturn(this, (_getPrototypeOf7 = getPrototypeOf(Xselection)).call.apply(_getPrototypeOf7, [this].concat(args)));

        _initialize6(assertThisInitialized(_this7));

        return _this7;
      }

      return Xselection;
    }(_Node12);

    return {
      F: Xselection,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "selection";
        }
      }]
    };
  }, Node);
  var Xpane = _decorate$1([props('xSplit', 'ySplit', 'topLeftCell', 'activePane', 'state')], function (_initialize7, _Node14) {
    var Xpane =
    /*#__PURE__*/
    function (_Node15) {
      inherits(Xpane, _Node15);

      function Xpane() {
        var _getPrototypeOf8;

        var _this8;

        classCallCheck(this, Xpane);

        for (var _len7 = arguments.length, args = new Array(_len7), _key7 = 0; _key7 < _len7; _key7++) {
          args[_key7] = arguments[_key7];
        }

        _this8 = possibleConstructorReturn(this, (_getPrototypeOf8 = getPrototypeOf(Xpane)).call.apply(_getPrototypeOf8, [this].concat(args)));

        _initialize7(assertThisInitialized(_this8));

        return _this8;
      }

      return Xpane;
    }(_Node14);

    return {
      F: Xpane,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "pane";
        }
      }]
    };
  }, Node);
  var XsheetFormatPr = _decorate$1([props('defaultColWidth', 'defaultRowHeight', 'outlineLevelCol', 'outlineLevelRow')], function (_initialize8, _Node16) {
    var XsheetFormatPr =
    /*#__PURE__*/
    function (_Node17) {
      inherits(XsheetFormatPr, _Node17);

      function XsheetFormatPr() {
        var _getPrototypeOf9;

        var _this9;

        classCallCheck(this, XsheetFormatPr);

        for (var _len8 = arguments.length, args = new Array(_len8), _key8 = 0; _key8 < _len8; _key8++) {
          args[_key8] = arguments[_key8];
        }

        _this9 = possibleConstructorReturn(this, (_getPrototypeOf9 = getPrototypeOf(XsheetFormatPr)).call.apply(_getPrototypeOf9, [this].concat(args)));

        _initialize8(assertThisInitialized(_this9));

        return _this9;
      }

      return XsheetFormatPr;
    }(_Node16);

    return {
      F: XsheetFormatPr,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "sheetFormatPr";
        }
      }]
    };
  }, Node);
  var Xcols =
  /*#__PURE__*/
  function (_Node18) {
    inherits(Xcols, _Node18);

    function Xcols() {
      var _getPrototypeOf10;

      var _this10;

      classCallCheck(this, Xcols);

      for (var _len9 = arguments.length, args = new Array(_len9), _key9 = 0; _key9 < _len9; _key9++) {
        args[_key9] = arguments[_key9];
      }

      _this10 = possibleConstructorReturn(this, (_getPrototypeOf10 = getPrototypeOf(Xcols)).call.apply(_getPrototypeOf10, [this].concat(args)));

      defineProperty(assertThisInitialized(_this10), "__name", "cols");

      return _this10;
    }

    return Xcols;
  }(Node);
  var Xcol = _decorate$1([props('collapsed', 'hidden', 'max', 'min', 'style', 'width', 'customWidth', 'outlineLevel')], function (_initialize9, _Node19) {
    var Xcol =
    /*#__PURE__*/
    function (_Node20) {
      inherits(Xcol, _Node20);

      function Xcol() {
        var _getPrototypeOf11;

        var _this11;

        classCallCheck(this, Xcol);

        for (var _len10 = arguments.length, args = new Array(_len10), _key10 = 0; _key10 < _len10; _key10++) {
          args[_key10] = arguments[_key10];
        }

        _this11 = possibleConstructorReturn(this, (_getPrototypeOf11 = getPrototypeOf(Xcol)).call.apply(_getPrototypeOf11, [this].concat(args)));

        _initialize9(assertThisInitialized(_this11));

        return _this11;
      }

      return Xcol;
    }(_Node19);

    return {
      F: Xcol,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "col";
        }
      }]
    };
  }, Node);
  var XsheetData =
  /*#__PURE__*/
  function (_Node21) {
    inherits(XsheetData, _Node21);

    function XsheetData() {
      var _getPrototypeOf12;

      var _this12;

      classCallCheck(this, XsheetData);

      for (var _len11 = arguments.length, args = new Array(_len11), _key11 = 0; _key11 < _len11; _key11++) {
        args[_key11] = arguments[_key11];
      }

      _this12 = possibleConstructorReturn(this, (_getPrototypeOf12 = getPrototypeOf(XsheetData)).call.apply(_getPrototypeOf12, [this].concat(args)));

      defineProperty(assertThisInitialized(_this12), "__name", "sheetData");

      return _this12;
    }

    return XsheetData;
  }(Node);
  var Xrow = _decorate$1([props('r', 'spans', 'hidden', 'ht', 'customHeight', 'outlineLevel')], function (_initialize10, _Node22) {
    var Xrow =
    /*#__PURE__*/
    function (_Node23) {
      inherits(Xrow, _Node23);

      function Xrow() {
        var _getPrototypeOf13;

        var _this13;

        classCallCheck(this, Xrow);

        for (var _len12 = arguments.length, args = new Array(_len12), _key12 = 0; _key12 < _len12; _key12++) {
          args[_key12] = arguments[_key12];
        }

        _this13 = possibleConstructorReturn(this, (_getPrototypeOf13 = getPrototypeOf(Xrow)).call.apply(_getPrototypeOf13, [this].concat(args)));

        _initialize10(assertThisInitialized(_this13));

        return _this13;
      }

      return Xrow;
    }(_Node22);

    return {
      F: Xrow,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "row";
        }
      }]
    };
  }, Node);
  var Xc = _decorate$1([props('r', 's', 't')], function (_initialize11, _Node24) {
    var Xc =
    /*#__PURE__*/
    function (_Node25) {
      inherits(Xc, _Node25);

      function Xc(attrs, children) {
        var _this14;

        classCallCheck(this, Xc);

        _this14 = possibleConstructorReturn(this, getPrototypeOf(Xc).call(this, attrs, children));

        _initialize11(assertThisInitialized(_this14));

        _this14.f = null;
        _this14.v = null;
        return _this14;
      }

      return Xc;
    }(_Node24);

    return {
      F: Xc,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "c";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          if (this.f !== null) this.children.push(this.f);
          if (this.v !== null) this.children.push(new Node({}, [this.v], 'v'));
          return get(getPrototypeOf(Xc.prototype), "render", this).call(this);
        }
      }]
    };
  }, Node);
  var Xf = _decorate$1([props('t', 'ref', 'si')], function (_initialize12, _Node26) {
    var Xf =
    /*#__PURE__*/
    function (_Node27) {
      inherits(Xf, _Node27);

      function Xf() {
        var _getPrototypeOf14;

        var _this15;

        classCallCheck(this, Xf);

        for (var _len13 = arguments.length, args = new Array(_len13), _key13 = 0; _key13 < _len13; _key13++) {
          args[_key13] = arguments[_key13];
        }

        _this15 = possibleConstructorReturn(this, (_getPrototypeOf14 = getPrototypeOf(Xf)).call.apply(_getPrototypeOf14, [this].concat(args)));

        _initialize12(assertThisInitialized(_this15));

        return _this15;
      }

      return Xf;
    }(_Node26);

    return {
      F: Xf,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "f";
        }
      }]
    };
  }, Node);
  var XmergeCells = _decorate$1([props('count')], function (_initialize13, _Node28) {
    var XmergeCells =
    /*#__PURE__*/
    function (_Node29) {
      inherits(XmergeCells, _Node29);

      function XmergeCells() {
        var _getPrototypeOf15;

        var _this16;

        classCallCheck(this, XmergeCells);

        for (var _len14 = arguments.length, args = new Array(_len14), _key14 = 0; _key14 < _len14; _key14++) {
          args[_key14] = arguments[_key14];
        }

        _this16 = possibleConstructorReturn(this, (_getPrototypeOf15 = getPrototypeOf(XmergeCells)).call.apply(_getPrototypeOf15, [this].concat(args)));

        _initialize13(assertThisInitialized(_this16));

        return _this16;
      }

      return XmergeCells;
    }(_Node28);

    return {
      F: XmergeCells,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "mergeCells";
        }
      }]
    };
  }, Node);
  var XmergeCell = _decorate$1([props('ref')], function (_initialize14, _Node30) {
    var XmergeCell =
    /*#__PURE__*/
    function (_Node31) {
      inherits(XmergeCell, _Node31);

      function XmergeCell() {
        var _getPrototypeOf16;

        var _this17;

        classCallCheck(this, XmergeCell);

        for (var _len15 = arguments.length, args = new Array(_len15), _key15 = 0; _key15 < _len15; _key15++) {
          args[_key15] = arguments[_key15];
        }

        _this17 = possibleConstructorReturn(this, (_getPrototypeOf16 = getPrototypeOf(XmergeCell)).call.apply(_getPrototypeOf16, [this].concat(args)));

        _initialize14(assertThisInitialized(_this17));

        return _this17;
      }

      return XmergeCell;
    }(_Node30);

    return {
      F: XmergeCell,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "mergeCell";
        }
      }]
    };
  }, Node);
  var XprintOptions = _decorate$1([props('headings', 'gridLines', 'gridLinesSet', 'horizontalCentered', 'verticalCentered')], function (_initialize15, _Node32) {
    var XprintOptions =
    /*#__PURE__*/
    function (_Node33) {
      inherits(XprintOptions, _Node33);

      function XprintOptions() {
        var _getPrototypeOf17;

        var _this18;

        classCallCheck(this, XprintOptions);

        for (var _len16 = arguments.length, args = new Array(_len16), _key16 = 0; _key16 < _len16; _key16++) {
          args[_key16] = arguments[_key16];
        }

        _this18 = possibleConstructorReturn(this, (_getPrototypeOf17 = getPrototypeOf(XprintOptions)).call.apply(_getPrototypeOf17, [this].concat(args)));

        _initialize15(assertThisInitialized(_this18));

        return _this18;
      }

      return XprintOptions;
    }(_Node32);

    return {
      F: XprintOptions,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "printOptions";
        }
      }]
    };
  }, Node);
  var XpageMargins = _decorate$1([props('left', 'right', 'top', 'bottom', 'header', 'footer')], function (_initialize16, _Node34) {
    var XpageMargins =
    /*#__PURE__*/
    function (_Node35) {
      inherits(XpageMargins, _Node35);

      function XpageMargins() {
        var _getPrototypeOf18;

        var _this19;

        classCallCheck(this, XpageMargins);

        for (var _len17 = arguments.length, args = new Array(_len17), _key17 = 0; _key17 < _len17; _key17++) {
          args[_key17] = arguments[_key17];
        }

        _this19 = possibleConstructorReturn(this, (_getPrototypeOf18 = getPrototypeOf(XpageMargins)).call.apply(_getPrototypeOf18, [this].concat(args)));

        _initialize16(assertThisInitialized(_this19));

        return _this19;
      }

      return XpageMargins;
    }(_Node34);

    return {
      F: XpageMargins,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "pageMargins";
        }
      }]
    };
  }, Node);
  var XpageSetup = _decorate$1([props('paperSize', 'scale', 'firstPageNumber', 'fitToWidth', 'fitToHeight', 'pageOrder', 'orientation', 'usePrinterDefaults', 'blackAndWhite', 'draft', 'cellComments', 'useFirstPageNumber', 'horizontalDpi', 'verticalDpi', 'copies')], function (_initialize17, _Node36) {
    var XpageSetup =
    /*#__PURE__*/
    function (_Node37) {
      inherits(XpageSetup, _Node37);

      function XpageSetup() {
        var _getPrototypeOf19;

        var _this20;

        classCallCheck(this, XpageSetup);

        for (var _len18 = arguments.length, args = new Array(_len18), _key18 = 0; _key18 < _len18; _key18++) {
          args[_key18] = arguments[_key18];
        }

        _this20 = possibleConstructorReturn(this, (_getPrototypeOf19 = getPrototypeOf(XpageSetup)).call.apply(_getPrototypeOf19, [this].concat(args)));

        _initialize17(assertThisInitialized(_this20));

        return _this20;
      }

      return XpageSetup;
    }(_Node36);

    return {
      F: XpageSetup,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "pageSetup";
        }
      }]
    };
  }, Node);
  var XheaderFooter = _decorate$1([props('differentFirst', 'differentOddEven')], function (_initialize18, _Node38) {
    var XheaderFooter =
    /*#__PURE__*/
    function (_Node39) {
      inherits(XheaderFooter, _Node39);

      function XheaderFooter(attrs, children) {
        var _this21;

        classCallCheck(this, XheaderFooter);

        _this21 = possibleConstructorReturn(this, getPrototypeOf(XheaderFooter).call(this, attrs, children));

        _initialize18(assertThisInitialized(_this21));

        _this21.oddHeader = null;
        _this21.oddFooter = null;
        return _this21;
      }

      return XheaderFooter;
    }(_Node38);

    return {
      F: XheaderFooter,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "headerFooter";
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          if (this.oddHeader !== null) this.children.push(new Node({}, [this.oddHeader], 'oddHeader'));
          if (this.oddFooter !== null) this.children.push(new Node({}, [this.oddFooter], 'oddFooter'));
          return get(getPrototypeOf(XheaderFooter.prototype), "render", this).call(this);
        }
      }]
    };
  }, Node);
  function makeXworksheet() {
    var sheet = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : new Xworksheet();
    sheet.sheetPr = new XsheetPr({
      filterMode: false
    }, [new XpageSetUpPr({
      fitToPage: false
    })]);
    sheet.sheetViews = new XsheetViews({}, [new XsheetView({
      colorId: 64,
      defaultGridColor: true,
      rightToLeft: false,
      showFormulas: false,
      showGridLines: true,
      showOutlineSymbols: true,
      showRowColHeaders: true,
      showZeros: true,
      tabSelected: false,
      topLeftCell: 'A1',
      view: 'normal',
      windowProtection: false,
      workbookViewId: 0,
      zoomScale: 100,
      zoomScaleNormal: 100,
      zoomScalePageLayoutView: 100
    }, [new Xselection({
      activeCell: 'A1',
      activeCellId: 0,
      pane: 'topLeft',
      sqref: 'A1'
    })])]);
    sheet.sheetFormatPr = new XsheetFormatPr({
      defaultRowHeight: '12.85'
    });
    sheet.printOptions = new XprintOptions({
      gridLines: false,
      gridLinesSet: true,
      headings: false,
      horizontalCentered: false,
      verticalCentered: false
    });
    sheet.pageMargins = new XpageMargins({
      left: 0.7875,
      right: 0.7875,
      top: 1.05277777777778,
      bottom: 1.05277777777778,
      header: 0.7875,
      footer: 0.7875
    });
    sheet.pageSetup = new XpageSetup({
      blackAndWhite: false,
      cellComments: 'none',
      copies: 1,
      draft: false,
      firstPageNumber: 1,
      fitToHeight: 1,
      fitToWidth: 1,
      horizontalDpi: 300,
      orientation: 'portrait',
      pageOrder: 'downThenOver',
      paperSize: 9,
      scale: 100,
      useFirstPageNumber: true,
      usePrinterDefaults: false,
      verticalDpi: 300
    });
    var headerFooter = new XheaderFooter();
    headerFooter.oddHeader = '&C&"Times New Roman,Regular"&12&A';
    headerFooter.oddFooter = '&C&"Times New Roman,Regular"&12Page &P';
    sheet.headerFooter = headerFooter;
    return sheet;
  }

  /**
   * Sheet of the xlsx file.
   * ```js
   * import { File } from 'better-xlsx';
   * const file = new File();
   * const sheet = file.addSheet('Sheet-1');
   * const row = sheet.addRow();
   * const cell = row.addCell();
   * ```
   */

  var Sheet =
  /*#__PURE__*/
  function () {
    function Sheet(_ref) {
      var name = _ref.name,
          file = _ref.file,
          selected = _ref.selected;

      classCallCheck(this, Sheet);

      defineProperty(this, "rows", []);

      defineProperty(this, "cols", []);

      defineProperty(this, "maxRow", 0);

      defineProperty(this, "maxCol", 0);

      defineProperty(this, "hidden", false);

      defineProperty(this, "sheetViews", []);

      defineProperty(this, "sheetFormat", {
        defaultColWidth: 0,
        defaultRowHeight: 0,
        outlineLevelCol: 0,
        outlineLevelRow: 0
      });

      this.name = name;
      this.file = file;
      this.selected = selected;
    }
    /**
     * Create a Row and add it into the Sheet.
     * @return {Row}
     */


    createClass(Sheet, [{
      key: "addRow",
      value: function addRow() {
        var row = new Row({
          sheet: this
        });
        this.rows.push(row);

        if (this.rows.length > this.maxRow) {
          this.maxRow = this.rows.length;
        }

        return row;
      }
    }, {
      key: "maybeAddCol",
      value: function maybeAddCol(cellCount) {
        if (cellCount > this.maxCol) {
          var col = new Col({
            min: cellCount,
            max: cellCount,
            hidden: false,
            collapsed: false
          });
          this.cols.push(col);
          this.maxCol = cellCount;
        }
      }
      /**
       * Get Col of the sheet with index and create cols when `index > maxCol`.
       * @param  {Number} idx Index of the Col [from 0].
       * @return {Col}
       */

    }, {
      key: "col",
      value: function col(idx) {
        this.maybeAddCol(idx + 1);
        return this.cols[idx];
      }
      /**
       * Get Row of the sheet with index and create rows when `index > maxRow`.
       * @param  {Number} idx Index of the Row [from 0].
       * @return {Row}
       */

    }, {
      key: "row",
      value: function row(idx) {
        for (var len = this.rows.length; len <= idx; len++) {
          this.addRow();
        }

        return this.rows[idx];
      }
      /**
       * Get Cell of the sheet with `(row, col)` and create cell when out of range.
       * @param  {Number} row
       * @param {Number} col
       * @return {Cell}
       */

    }, {
      key: "cell",
      value: function cell(row, col) {
        for (var len = this.rows.length; len <= row; len++) {
          this.addRow();
        }

        var r = this.rows[row];

        for (var _len = r.cells.length; _len <= col; _len++) {
          r.addCell();
        }

        return r.cells[col];
      }
      /**
       * Set columns width from `startcol` to `endcol`.
       * @param {Number} startcol
       * @param {Number} endcol
       * @param {Number} width
       */

    }, {
      key: "setColWidth",
      value: function setColWidth(startcol, endcol, width) {
        if (startcol > endcol) {
          throw new Error("Could not set width for range ".concat(startcol, "-").concat(endcol, ": startcol must be less than endcol."));
        }

        var col = new Col({
          min: startcol + 1,
          max: endcol + 1,
          hidden: false,
          collapsed: false,
          width: width
        });
        this.cols.push(col);

        if (endcol + 1 > this.maxCol) {
          this.maxCol = endcol + 1;
        }
      }
    }, {
      key: "handleMerged",
      value: function handleMerged() {
        var merged = [];

        for (var r = 0; r < this.rows.length; r++) {
          var row = this.rows[r];

          for (var c = 0; c < row.cells.length; c++) {
            var cell = row.cells[c];

            if (cell.hMerge > 0 || cell.vMerge > 0) {
              merged.push({
                r: r,
                c: c,
                cell: cell
              });
            }
          }
        }

        for (var _i = 0, _merged = merged; _i < _merged.length; _i++) {
          var _merged$_i = _merged[_i],
              _r = _merged$_i.r,
              _c = _merged$_i.c,
              _cell = _merged$_i.cell;
          var left = _cell.style.border.left;
          var right = _cell.style.border.right;
          var top = _cell.style.border.top;
          var bottom = _cell.style.border.bottom;
          _cell.style.border.left = 'none';
          _cell.style.border.right = 'none';
          _cell.style.border.top = 'none';
          _cell.style.border.bottom = 'none';

          for (var rownum = 0; rownum <= _cell.vMerge; rownum++) {
            for (var colnum = 0; colnum <= _cell.hMerge; colnum++) {
              var tmpcell = this.cell(_r + rownum, _c + colnum);
              tmpcell.style.applyBorder = true;

              if (rownum === 0) {
                tmpcell.style.border.top = top;
              }

              if (rownum === _cell.vMerge) {
                tmpcell.style.border.bottom = bottom;
              }

              if (colnum === 0) {
                tmpcell.style.border.left = left;
              }

              if (colnum === _cell.hMerge) {
                tmpcell.style.border.right = right;
              }
            }
          }
        }
      }
    }, {
      key: "makeXSheet",
      value: function makeXSheet(refTable, styles) {
        var sheet = makeXworksheet();
        var xSheet = new XsheetData();
        var maxRow = 0;
        var maxCell = 0;
        var maxLevelCol;
        var maxLevelRow;
        this.handleMerged();

        for (var i = 0; i < this.sheetViews.length; i++) {
          var view = this.sheetViews[i];

          if (view && view.pane) {
            sheet.sheetViews.children[i].children.push(new Xpane({
              xSplit: view.pane.xSplit,
              ySplit: view.pane.ySplit,
              topLeftCell: view.pane.topLeftCell,
              activePane: view.pane.activePane,
              state: view.pane.state
            }));
          }
        }

        if (this.selected) {
          sheet.sheetViews.children[0].tabSelected = true;
        }

        if (this.sheetFormat.defaultRowHeight !== 0) {
          sheet.sheetFormatPr.defaultRowHeight = this.sheetFormat.defaultRowHeight;
        }

        if (this.sheetFormat.defaultColWidth !== 0) {
          sheet.sheetFormatPr.defaultColWidth = this.sheetFormat.defaultColWidth;
        }

        var fIdList = [];
        sheet.cols = new Xcols();

        for (var c = 0; c < this.cols.length; c++) {
          var col = this.cols[c];
          col.min = col.min || 1;
          col.max = col.max || 1;
          var xNumFmt = styles.newNumFmt(col.numFmt);
          var fId = handleStyle(col.style, xNumFmt.numFmtId, styles);
          fIdList.push(fId);
          var customWidth = 0;

          if (col.width === 0) {
            col.width = 9.5;
          } else {
            customWidth = 1;
          }

          sheet.cols.children.push(new Xcol({
            min: col.min,
            max: col.max,
            hidden: col.hidden,
            width: col.width,
            customWidth: customWidth,
            collapsed: col.collapsed,
            outlineLevel: col.outlineLevel,
            style: fId
          }));

          if (col.outlineLevel > maxLevelCol) {
            maxLevelCol = col.outlineLevel;
          }
        }

        for (var r = 0; r < this.rows.length; r++) {
          var row = this.rows[r];
          if (r > maxRow) maxRow = r;
          var xRow = new Xrow({
            r: r + 1
          });

          if (row.isCustom) {
            xRow.customHeight = true;
            xRow.ht = row.height;
          }

          xRow.outlineLevel = row.outlineLevel;

          if (row.outlineLevel > maxLevelRow) {
            maxLevelRow = row.outlineLevel;
          }

          for (var _c2 = 0; _c2 < row.cells.length; _c2++) {
            var _fId = fIdList[_c2];
            var cell = row.cells[_c2];

            var _xNumFmt = styles.newNumFmt(cell.numFmt);

            var style = cell.style;

            if (style !== null) {
              _fId = handleStyle(style, _xNumFmt.numFmtId, styles);
            } else if (cell.numFmt && this.cols[_c2].numFmt !== cell.numFmt) {
              _fId = handleNumFmtId(_xNumFmt.NumFmtId, styles);
            }

            if (_c2 > maxCell) maxCell = _c2;
            var xC = new Xc({
              r: "".concat(num2col(_c2)).concat(r + 1)
            });

            switch (cell.cellType) {
              case 'TypeString':
                if (cell.value) {
                  xC.v = refTable.addString(cell.value);
                }

                xC.t = 's';
                xC.s = _fId;
                break;

              case 'TypeBool':
                xC.v = cell.value;
                xC.t = 'b';
                xC.s = _fId;
                break;

              case 'TypeNumeric':
                xC.v = cell.value;
                xC.s = _fId;
                break;

              case 'TypeDate':
                xC.v = cell.value;
                xC.s = _fId;
                break;

              case 'TypeFormula':
                xC.v = cell.value;
                xC.f = new Xf({}, [cell.formula]);
                xC.s = _fId;
                break;

              case 'TypeError':
                xC.v = cell.value;
                xC.f = new Xf({}, [cell.formula]);
                xC.t = 'e';
                xC.s = _fId;
                break;

              case 'TypeGeneral':
                xC.v = cell.value;
                xC.s = _fId;
                break;
            }

            xRow.children.push(xC);

            if (cell.hMerge > 0 || cell.vMerge > 0) {
              // r == rownum, c == colnum
              var start = "".concat(num2col(_c2)).concat(r + 1);
              var endcol = _c2 + cell.hMerge;
              var endrow = r + cell.vMerge + 1;
              var end = "".concat(num2col(endcol)).concat(endrow);
              var mc = new XmergeCell({
                ref: start + ':' + end
              });

              if (sheet.mergeCells === null) {
                sheet.mergeCells = new XmergeCells();
              }

              sheet.mergeCells.children.push(mc);
            }
          }

          xSheet.children.push(xRow);
        } // Update sheet format with the freshly determined max levels


        this.sheetFormat.outlineLevelCol = maxLevelCol;
        this.sheetFormat.outlineLevelRow = maxLevelRow; // .. and then also apply this to the xml worksheet

        sheet.sheetFormatPr.outlineLevelCol = this.sheetFormat.outlineLevelCol;
        sheet.sheetFormatPr.outlineLevelRow = this.sheetFormat.outlineLevelRow;

        if (sheet.mergeCells !== null) {
          sheet.mergeCells.count = sheet.mergeCells.children.length;
        }

        sheet.sheetData = xSheet;
        var dimension = new Xdimension({
          ref: "A1:".concat(num2col(maxCell)).concat(maxRow + 1)
        });

        if (dimension.ref === 'A1:A1') {
          dimension.ref = 'A1';
        }

        sheet.dimension = dimension;

        if (this.afterMake) {
          this.afterMake(sheet);
        }

        return sheet;
      }
    }]);

    return Sheet;
  }();

  var sheet = /*#__PURE__*/Object.freeze({
    Sheet: Sheet
  });

  var DOT_RELS = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">\n  <Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/>\n  <Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties\" Target=\"docProps/core.xml\"/>\n  <Relationship Id=\"rId3\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties\" Target=\"docProps/app.xml\"/>\n</Relationships>";
  var DOCPROPS_APP = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<Properties xmlns=\"http://schemas.openxmlformats.org/officeDocument/2006/extended-properties\" xmlns:vt=\"http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes\">\n  <TotalTime>0</TotalTime>\n  <Application>JS XLSX</Application>\n</Properties>";
  var DOCPROPS_CORE = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<cp:coreProperties xmlns:cp=\"http://schemas.openxmlformats.org/package/2006/metadata/core-properties\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcmitype=\"http://purl.org/dc/dcmitype/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"></cp:coreProperties>";
  var XL_THEME_THEME = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<a:theme xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" name=\"Office-Design\">\n  <a:themeElements>\n    <a:clrScheme name=\"Office\">\n      <a:dk1>\n        <a:sysClr val=\"windowText\" lastClr=\"000000\"/>\n      </a:dk1>\n      <a:lt1>\n        <a:sysClr val=\"window\" lastClr=\"FFFFFF\"/>\n      </a:lt1>\n      <a:dk2>\n        <a:srgbClr val=\"1F497D\"/>\n      </a:dk2>\n      <a:lt2>\n        <a:srgbClr val=\"EEECE1\"/>\n      </a:lt2>\n      <a:accent1>\n        <a:srgbClr val=\"4F81BD\"/>\n      </a:accent1>\n      <a:accent2>\n        <a:srgbClr val=\"C0504D\"/>\n      </a:accent2>\n      <a:accent3>\n        <a:srgbClr val=\"9BBB59\"/>\n      </a:accent3>\n      <a:accent4>\n        <a:srgbClr val=\"8064A2\"/>\n      </a:accent4>\n      <a:accent5>\n        <a:srgbClr val=\"4BACC6\"/>\n      </a:accent5>\n      <a:accent6>\n        <a:srgbClr val=\"F79646\"/>\n      </a:accent6>\n      <a:hlink>\n        <a:srgbClr val=\"0000FF\"/>\n      </a:hlink>\n      <a:folHlink>\n        <a:srgbClr val=\"800080\"/>\n      </a:folHlink>\n    </a:clrScheme>\n    <a:fontScheme name=\"Office\">\n      <a:majorFont>\n        <a:latin typeface=\"Cambria\"/>\n        <a:ea typeface=\"\"/>\n        <a:cs typeface=\"\"/>\n        <a:font script=\"Jpan\" typeface=\"\uFF2D\uFF33 \uFF30\u30B4\u30B7\u30C3\u30AF\"/>\n        <a:font script=\"Hang\" typeface=\"\uB9D1\uC740 \uACE0\uB515\"/>\n        <a:font script=\"Hans\" typeface=\"\u5B8B\u4F53\"/>\n        <a:font script=\"Hant\" typeface=\"\u65B0\u7D30\u660E\u9AD4\"/>\n        <a:font script=\"Arab\" typeface=\"Times New Roman\"/>\n        <a:font script=\"Hebr\" typeface=\"Times New Roman\"/>\n        <a:font script=\"Thai\" typeface=\"Tahoma\"/>\n        <a:font script=\"Ethi\" typeface=\"Nyala\"/>\n        <a:font script=\"Beng\" typeface=\"Vrinda\"/>\n        <a:font script=\"Gujr\" typeface=\"Shruti\"/>\n        <a:font script=\"Khmr\" typeface=\"MoolBoran\"/>\n        <a:font script=\"Knda\" typeface=\"Tunga\"/>\n        <a:font script=\"Guru\" typeface=\"Raavi\"/>\n        <a:font script=\"Cans\" typeface=\"Euphemia\"/>\n        <a:font script=\"Cher\" typeface=\"Plantagenet Cherokee\"/>\n        <a:font script=\"Yiii\" typeface=\"Microsoft Yi Baiti\"/>\n        <a:font script=\"Tibt\" typeface=\"Microsoft Himalaya\"/>\n        <a:font script=\"Thaa\" typeface=\"MV Boli\"/>\n        <a:font script=\"Deva\" typeface=\"Mangal\"/>\n        <a:font script=\"Telu\" typeface=\"Gautami\"/>\n        <a:font script=\"Taml\" typeface=\"Latha\"/>\n        <a:font script=\"Syrc\" typeface=\"Estrangelo Edessa\"/>\n        <a:font script=\"Orya\" typeface=\"Kalinga\"/>\n        <a:font script=\"Mlym\" typeface=\"Kartika\"/>\n        <a:font script=\"Laoo\" typeface=\"DokChampa\"/>\n        <a:font script=\"Sinh\" typeface=\"Iskoola Pota\"/>\n        <a:font script=\"Mong\" typeface=\"Mongolian Baiti\"/>\n        <a:font script=\"Viet\" typeface=\"Times New Roman\"/>\n        <a:font script=\"Uigh\" typeface=\"Microsoft Uighur\"/>\n        <a:font script=\"Geor\" typeface=\"Sylfaen\"/>\n      </a:majorFont>\n      <a:minorFont>\n        <a:latin typeface=\"Calibri\"/>\n        <a:ea typeface=\"\"/>\n        <a:cs typeface=\"\"/>\n        <a:font script=\"Jpan\" typeface=\"\uFF2D\uFF33 \uFF30\u30B4\u30B7\u30C3\u30AF\"/>\n        <a:font script=\"Hang\" typeface=\"\uB9D1\uC740 \uACE0\uB515\"/>\n        <a:font script=\"Hans\" typeface=\"\u5B8B\u4F53\"/>\n        <a:font script=\"Hant\" typeface=\"\u65B0\u7D30\u660E\u9AD4\"/>\n        <a:font script=\"Arab\" typeface=\"Arial\"/>\n        <a:font script=\"Hebr\" typeface=\"Arial\"/>\n        <a:font script=\"Thai\" typeface=\"Tahoma\"/>\n        <a:font script=\"Ethi\" typeface=\"Nyala\"/>\n        <a:font script=\"Beng\" typeface=\"Vrinda\"/>\n        <a:font script=\"Gujr\" typeface=\"Shruti\"/>\n        <a:font script=\"Khmr\" typeface=\"DaunPenh\"/>\n        <a:font script=\"Knda\" typeface=\"Tunga\"/>\n        <a:font script=\"Guru\" typeface=\"Raavi\"/>\n        <a:font script=\"Cans\" typeface=\"Euphemia\"/>\n        <a:font script=\"Cher\" typeface=\"Plantagenet Cherokee\"/>\n        <a:font script=\"Yiii\" typeface=\"Microsoft Yi Baiti\"/>\n        <a:font script=\"Tibt\" typeface=\"Microsoft Himalaya\"/>\n        <a:font script=\"Thaa\" typeface=\"MV Boli\"/>\n        <a:font script=\"Deva\" typeface=\"Mangal\"/>\n        <a:font script=\"Telu\" typeface=\"Gautami\"/>\n        <a:font script=\"Taml\" typeface=\"Latha\"/>\n        <a:font script=\"Syrc\" typeface=\"Estrangelo Edessa\"/>\n        <a:font script=\"Orya\" typeface=\"Kalinga\"/>\n        <a:font script=\"Mlym\" typeface=\"Kartika\"/>\n        <a:font script=\"Laoo\" typeface=\"DokChampa\"/>\n        <a:font script=\"Sinh\" typeface=\"Iskoola Pota\"/>\n        <a:font script=\"Mong\" typeface=\"Mongolian Baiti\"/>\n        <a:font script=\"Viet\" typeface=\"Arial\"/>\n        <a:font script=\"Uigh\" typeface=\"Microsoft Uighur\"/>\n        <a:font script=\"Geor\" typeface=\"Sylfaen\"/>\n      </a:minorFont>\n    </a:fontScheme>\n    <a:fmtScheme name=\"Office\">\n      <a:fillStyleLst>\n        <a:solidFill>\n          <a:schemeClr val=\"phClr\"/>\n        </a:solidFill>\n        <a:gradFill rotWithShape=\"1\">\n          <a:gsLst>\n            <a:gs pos=\"0\">\n              <a:schemeClr val=\"phClr\">\n                <a:tint val=\"50000\"/>\n                <a:satMod val=\"300000\"/>\n              </a:schemeClr>\n            </a:gs>\n            <a:gs pos=\"35000\">\n              <a:schemeClr val=\"phClr\">\n                <a:tint val=\"37000\"/>\n                <a:satMod val=\"300000\"/>\n              </a:schemeClr>\n            </a:gs>\n            <a:gs pos=\"100000\">\n              <a:schemeClr val=\"phClr\">\n                <a:tint val=\"15000\"/>\n                <a:satMod val=\"350000\"/>\n              </a:schemeClr>\n            </a:gs>\n          </a:gsLst>\n          <a:lin ang=\"16200000\" scaled=\"1\"/>\n        </a:gradFill>\n        <a:gradFill rotWithShape=\"1\">\n          <a:gsLst>\n            <a:gs pos=\"0\">\n              <a:schemeClr val=\"phClr\">\n                <a:tint val=\"100000\"/>\n                <a:shade val=\"100000\"/>\n                <a:satMod val=\"130000\"/>\n              </a:schemeClr>\n            </a:gs>\n            <a:gs pos=\"100000\">\n              <a:schemeClr val=\"phClr\">\n                <a:tint val=\"50000\"/>\n                <a:shade val=\"100000\"/>\n                <a:satMod val=\"350000\"/>\n              </a:schemeClr>\n            </a:gs>\n          </a:gsLst>\n          <a:lin ang=\"16200000\" scaled=\"0\"/>\n        </a:gradFill>\n      </a:fillStyleLst>\n      <a:lnStyleLst>\n        <a:ln w=\"9525\" cap=\"flat\" cmpd=\"sng\" algn=\"ctr\">\n          <a:solidFill>\n            <a:schemeClr val=\"phClr\">\n              <a:shade val=\"95000\"/>\n              <a:satMod val=\"105000\"/>\n            </a:schemeClr>\n          </a:solidFill>\n          <a:prstDash val=\"solid\"/>\n        </a:ln>\n        <a:ln w=\"25400\" cap=\"flat\" cmpd=\"sng\" algn=\"ctr\">\n          <a:solidFill>\n            <a:schemeClr val=\"phClr\"/>\n          </a:solidFill>\n          <a:prstDash val=\"solid\"/>\n        </a:ln>\n        <a:ln w=\"38100\" cap=\"flat\" cmpd=\"sng\" algn=\"ctr\">\n          <a:solidFill>\n            <a:schemeClr val=\"phClr\"/>\n          </a:solidFill>\n          <a:prstDash val=\"solid\"/>\n        </a:ln>\n      </a:lnStyleLst>\n      <a:effectStyleLst>\n        <a:effectStyle>\n          <a:effectLst>\n            <a:outerShdw blurRad=\"40000\" dist=\"20000\" dir=\"5400000\" rotWithShape=\"0\">\n              <a:srgbClr val=\"000000\">\n                <a:alpha val=\"38000\"/>\n              </a:srgbClr>\n            </a:outerShdw>\n          </a:effectLst>\n        </a:effectStyle>\n        <a:effectStyle>\n          <a:effectLst>\n            <a:outerShdw blurRad=\"40000\" dist=\"23000\" dir=\"5400000\" rotWithShape=\"0\">\n              <a:srgbClr val=\"000000\">\n                <a:alpha val=\"35000\"/>\n              </a:srgbClr>\n            </a:outerShdw>\n          </a:effectLst>\n        </a:effectStyle>\n        <a:effectStyle>\n          <a:effectLst>\n            <a:outerShdw blurRad=\"40000\" dist=\"23000\" dir=\"5400000\" rotWithShape=\"0\">\n              <a:srgbClr val=\"000000\">\n                <a:alpha val=\"35000\"/>\n              </a:srgbClr>\n            </a:outerShdw>\n          </a:effectLst>\n          <a:scene3d>\n            <a:camera prst=\"orthographicFront\">\n              <a:rot lat=\"0\" lon=\"0\" rev=\"0\"/>\n            </a:camera>\n            <a:lightRig rig=\"threePt\" dir=\"t\">\n              <a:rot lat=\"0\" lon=\"0\" rev=\"1200000\"/>\n            </a:lightRig>\n          </a:scene3d>\n          <a:sp3d>\n            <a:bevelT w=\"63500\" h=\"25400\"/>\n          </a:sp3d>\n        </a:effectStyle>\n      </a:effectStyleLst>\n      <a:bgFillStyleLst>\n        <a:solidFill>\n          <a:schemeClr val=\"phClr\"/>\n        </a:solidFill>\n        <a:gradFill rotWithShape=\"1\">\n          <a:gsLst>\n            <a:gs pos=\"0\">\n              <a:schemeClr val=\"phClr\">\n                <a:tint val=\"40000\"/>\n                <a:satMod val=\"350000\"/>\n              </a:schemeClr>\n            </a:gs>\n            <a:gs pos=\"40000\">\n              <a:schemeClr val=\"phClr\">\n                <a:tint val=\"45000\"/>\n                <a:shade val=\"99000\"/>\n                <a:satMod val=\"350000\"/>\n              </a:schemeClr>\n            </a:gs>\n            <a:gs pos=\"100000\">\n              <a:schemeClr val=\"phClr\">\n                <a:shade val=\"20000\"/>\n                <a:satMod val=\"255000\"/>\n              </a:schemeClr>\n            </a:gs>\n          </a:gsLst>\n          <a:path path=\"circle\">\n            <a:fillToRect l=\"50000\" t=\"-80000\" r=\"50000\" b=\"180000\"/>\n          </a:path>\n        </a:gradFill>\n        <a:gradFill rotWithShape=\"1\">\n          <a:gsLst>\n            <a:gs pos=\"0\">\n              <a:schemeClr val=\"phClr\">\n                <a:tint val=\"80000\"/>\n                <a:satMod val=\"300000\"/>\n              </a:schemeClr>\n            </a:gs>\n            <a:gs pos=\"100000\">\n              <a:schemeClr val=\"phClr\">\n                <a:shade val=\"30000\"/>\n                <a:satMod val=\"200000\"/>\n              </a:schemeClr>\n            </a:gs>\n          </a:gsLst>\n          <a:path path=\"circle\">\n            <a:fillToRect l=\"50000\" t=\"50000\" r=\"50000\" b=\"50000\"/>\n          </a:path>\n        </a:gradFill>\n      </a:bgFillStyleLst>\n    </a:fmtScheme>\n  </a:themeElements>\n  <a:objectDefaults>\n    <a:spDef>\n      <a:spPr/>\n      <a:bodyPr/>\n      <a:lstStyle/>\n      <a:style>\n        <a:lnRef idx=\"1\">\n          <a:schemeClr val=\"accent1\"/>\n        </a:lnRef>\n        <a:fillRef idx=\"3\">\n          <a:schemeClr val=\"accent1\"/>\n        </a:fillRef>\n        <a:effectRef idx=\"2\">\n          <a:schemeClr val=\"accent1\"/>\n        </a:effectRef>\n        <a:fontRef idx=\"minor\">\n          <a:schemeClr val=\"lt1\"/>\n        </a:fontRef>\n      </a:style>\n    </a:spDef>\n    <a:lnDef>\n      <a:spPr/>\n      <a:bodyPr/>\n      <a:lstStyle/>\n      <a:style>\n        <a:lnRef idx=\"2\">\n          <a:schemeClr val=\"accent1\"/>\n        </a:lnRef>\n        <a:fillRef idx=\"0\">\n          <a:schemeClr val=\"accent1\"/>\n        </a:fillRef>\n        <a:effectRef idx=\"1\">\n          <a:schemeClr val=\"accent1\"/>\n        </a:effectRef>\n        <a:fontRef idx=\"minor\">\n          <a:schemeClr val=\"tx1\"/>\n        </a:fontRef>\n      </a:style>\n    </a:lnDef>\n  </a:objectDefaults>\n  <a:extraClrSchemeLst/>\n</a:theme>";

  function _decorate$2(decorators, factory, superClass, mixins) { var api = _getDecoratorsApi$2(); if (mixins) { for (var i = 0; i < mixins.length; i++) { api = mixins[i](api); } } var r = factory(function initialize(O) { api.initializeInstanceElements(O, decorated.elements); }, superClass); var decorated = api.decorateClass(_coalesceClassElements$2(r.d.map(_createElementDescriptor$2)), decorators); api.initializeClassElements(r.F, decorated.elements); return api.runClassFinishers(r.F, decorated.finishers); }

  function _getDecoratorsApi$2() { _getDecoratorsApi$2 = function _getDecoratorsApi() { return api; }; var api = { elementsDefinitionOrder: [["method"], ["field"]], initializeInstanceElements: function initializeInstanceElements(O, elements) { ["method", "field"].forEach(function (kind) { elements.forEach(function (element) { if (element.kind === kind && element.placement === "own") { this.defineClassElement(O, element); } }, this); }, this); }, initializeClassElements: function initializeClassElements(F, elements) { var proto = F.prototype; ["method", "field"].forEach(function (kind) { elements.forEach(function (element) { var placement = element.placement; if (element.kind === kind && (placement === "static" || placement === "prototype")) { var receiver = placement === "static" ? F : proto; this.defineClassElement(receiver, element); } }, this); }, this); }, defineClassElement: function defineClassElement(receiver, element) { var descriptor = element.descriptor; if (element.kind === "field") { var initializer = element.initializer; descriptor = { enumerable: descriptor.enumerable, writable: descriptor.writable, configurable: descriptor.configurable, value: initializer === void 0 ? void 0 : initializer.call(receiver) }; } Object.defineProperty(receiver, element.key, descriptor); }, decorateClass: function decorateClass(elements, decorators) { var newElements = []; var finishers = []; var placements = { "static": [], prototype: [], own: [] }; elements.forEach(function (element) { this.addElementPlacement(element, placements); }, this); elements.forEach(function (element) { if (!_hasDecorators$2(element)) return newElements.push(element); var elementFinishersExtras = this.decorateElement(element, placements); newElements.push(elementFinishersExtras.element); newElements.push.apply(newElements, elementFinishersExtras.extras); finishers.push.apply(finishers, elementFinishersExtras.finishers); }, this); if (!decorators) { return { elements: newElements, finishers: finishers }; } var result = this.decorateConstructor(newElements, decorators); finishers.push.apply(finishers, result.finishers); result.finishers = finishers; return result; }, addElementPlacement: function addElementPlacement(element, placements, silent) { var keys = placements[element.placement]; if (!silent && keys.indexOf(element.key) !== -1) { throw new TypeError("Duplicated element (" + element.key + ")"); } keys.push(element.key); }, decorateElement: function decorateElement(element, placements) { var extras = []; var finishers = []; for (var decorators = element.decorators, i = decorators.length - 1; i >= 0; i--) { var keys = placements[element.placement]; keys.splice(keys.indexOf(element.key), 1); var elementObject = this.fromElementDescriptor(element); var elementFinisherExtras = this.toElementFinisherExtras((0, decorators[i])(elementObject) || elementObject); element = elementFinisherExtras.element; this.addElementPlacement(element, placements); if (elementFinisherExtras.finisher) { finishers.push(elementFinisherExtras.finisher); } var newExtras = elementFinisherExtras.extras; if (newExtras) { for (var j = 0; j < newExtras.length; j++) { this.addElementPlacement(newExtras[j], placements); } extras.push.apply(extras, newExtras); } } return { element: element, finishers: finishers, extras: extras }; }, decorateConstructor: function decorateConstructor(elements, decorators) { var finishers = []; for (var i = decorators.length - 1; i >= 0; i--) { var obj = this.fromClassDescriptor(elements); var elementsAndFinisher = this.toClassDescriptor((0, decorators[i])(obj) || obj); if (elementsAndFinisher.finisher !== undefined) { finishers.push(elementsAndFinisher.finisher); } if (elementsAndFinisher.elements !== undefined) { elements = elementsAndFinisher.elements; for (var j = 0; j < elements.length - 1; j++) { for (var k = j + 1; k < elements.length; k++) { if (elements[j].key === elements[k].key && elements[j].placement === elements[k].placement) { throw new TypeError("Duplicated element (" + elements[j].key + ")"); } } } } } return { elements: elements, finishers: finishers }; }, fromElementDescriptor: function fromElementDescriptor(element) { var obj = { kind: element.kind, key: element.key, placement: element.placement, descriptor: element.descriptor }; var desc = { value: "Descriptor", configurable: true }; Object.defineProperty(obj, Symbol.toStringTag, desc); if (element.kind === "field") obj.initializer = element.initializer; return obj; }, toElementDescriptors: function toElementDescriptors(elementObjects) { if (elementObjects === undefined) return; return toArray(elementObjects).map(function (elementObject) { var element = this.toElementDescriptor(elementObject); this.disallowProperty(elementObject, "finisher", "An element descriptor"); this.disallowProperty(elementObject, "extras", "An element descriptor"); return element; }, this); }, toElementDescriptor: function toElementDescriptor(elementObject) { var kind = String(elementObject.kind); if (kind !== "method" && kind !== "field") { throw new TypeError('An element descriptor\'s .kind property must be either "method" or' + ' "field", but a decorator created an element descriptor with' + ' .kind "' + kind + '"'); } var key = _toPropertyKey$2(elementObject.key); var placement = String(elementObject.placement); if (placement !== "static" && placement !== "prototype" && placement !== "own") { throw new TypeError('An element descriptor\'s .placement property must be one of "static",' + ' "prototype" or "own", but a decorator created an element descriptor' + ' with .placement "' + placement + '"'); } var descriptor = elementObject.descriptor; this.disallowProperty(elementObject, "elements", "An element descriptor"); var element = { kind: kind, key: key, placement: placement, descriptor: Object.assign({}, descriptor) }; if (kind !== "field") { this.disallowProperty(elementObject, "initializer", "A method descriptor"); } else { this.disallowProperty(descriptor, "get", "The property descriptor of a field descriptor"); this.disallowProperty(descriptor, "set", "The property descriptor of a field descriptor"); this.disallowProperty(descriptor, "value", "The property descriptor of a field descriptor"); element.initializer = elementObject.initializer; } return element; }, toElementFinisherExtras: function toElementFinisherExtras(elementObject) { var element = this.toElementDescriptor(elementObject); var finisher = _optionalCallableProperty$2(elementObject, "finisher"); var extras = this.toElementDescriptors(elementObject.extras); return { element: element, finisher: finisher, extras: extras }; }, fromClassDescriptor: function fromClassDescriptor(elements) { var obj = { kind: "class", elements: elements.map(this.fromElementDescriptor, this) }; var desc = { value: "Descriptor", configurable: true }; Object.defineProperty(obj, Symbol.toStringTag, desc); return obj; }, toClassDescriptor: function toClassDescriptor(obj) { var kind = String(obj.kind); if (kind !== "class") { throw new TypeError('A class descriptor\'s .kind property must be "class", but a decorator' + ' created a class descriptor with .kind "' + kind + '"'); } this.disallowProperty(obj, "key", "A class descriptor"); this.disallowProperty(obj, "placement", "A class descriptor"); this.disallowProperty(obj, "descriptor", "A class descriptor"); this.disallowProperty(obj, "initializer", "A class descriptor"); this.disallowProperty(obj, "extras", "A class descriptor"); var finisher = _optionalCallableProperty$2(obj, "finisher"); var elements = this.toElementDescriptors(obj.elements); return { elements: elements, finisher: finisher }; }, runClassFinishers: function runClassFinishers(constructor, finishers) { for (var i = 0; i < finishers.length; i++) { var newConstructor = (0, finishers[i])(constructor); if (newConstructor !== undefined) { if (typeof newConstructor !== "function") { throw new TypeError("Finishers must return a constructor."); } constructor = newConstructor; } } return constructor; }, disallowProperty: function disallowProperty(obj, name, objectType) { if (obj[name] !== undefined) { throw new TypeError(objectType + " can't have a ." + name + " property."); } } }; return api; }

  function _createElementDescriptor$2(def) { var key = _toPropertyKey$2(def.key); var descriptor; if (def.kind === "method") { descriptor = { value: def.value, writable: true, configurable: true, enumerable: false }; } else if (def.kind === "get") { descriptor = { get: def.value, configurable: true, enumerable: false }; } else if (def.kind === "set") { descriptor = { set: def.value, configurable: true, enumerable: false }; } else if (def.kind === "field") { descriptor = { configurable: true, writable: true, enumerable: true }; } var element = { kind: def.kind === "field" ? "field" : "method", key: key, placement: def["static"] ? "static" : def.kind === "field" ? "own" : "prototype", descriptor: descriptor }; if (def.decorators) element.decorators = def.decorators; if (def.kind === "field") element.initializer = def.value; return element; }

  function _coalesceGetterSetter$2(element, other) { if (element.descriptor.get !== undefined) { other.descriptor.get = element.descriptor.get; } else { other.descriptor.set = element.descriptor.set; } }

  function _coalesceClassElements$2(elements) { var newElements = []; var isSameElement = function isSameElement(other) { return other.kind === "method" && other.key === element.key && other.placement === element.placement; }; for (var i = 0; i < elements.length; i++) { var element = elements[i]; var other; if (element.kind === "method" && (other = newElements.find(isSameElement))) { if (_isDataDescriptor$2(element.descriptor) || _isDataDescriptor$2(other.descriptor)) { if (_hasDecorators$2(element) || _hasDecorators$2(other)) { throw new ReferenceError("Duplicated methods (" + element.key + ") can't be decorated."); } other.descriptor = element.descriptor; } else { if (_hasDecorators$2(element)) { if (_hasDecorators$2(other)) { throw new ReferenceError("Decorators can't be placed on different accessors with for " + "the same property (" + element.key + ")."); } other.decorators = element.decorators; } _coalesceGetterSetter$2(element, other); } } else { newElements.push(element); } } return newElements; }

  function _hasDecorators$2(element) { return element.decorators && element.decorators.length; }

  function _isDataDescriptor$2(desc) { return desc !== undefined && !(desc.value === undefined && desc.writable === undefined); }

  function _optionalCallableProperty$2(obj, name) { var value = obj[name]; if (value !== undefined && typeof value !== "function") { throw new TypeError("Expected '" + name + "' to be a function"); } return value; }

  function _toPropertyKey$2(arg) { var key = _toPrimitive$2(arg, "string"); return _typeof_1(key) === "symbol" ? key : String(key); }

  function _toPrimitive$2(input, hint) { if (_typeof_1(input) !== "object" || input === null) return input; var prim = input[Symbol.toPrimitive]; if (prim !== undefined) { var res = prim.call(input, hint || "default"); if (_typeof_1(res) !== "object") return res; throw new TypeError("@@toPrimitive must return a primitive value."); } return (hint === "string" ? String : Number)(input); }
  var Xsst = _decorate$2([props('xmlns', 'count', 'uniqueCount')], function (_initialize, _Node) {
    var Xsst =
    /*#__PURE__*/
    function (_Node2) {
      inherits(Xsst, _Node2);

      function Xsst(_ref, children) {
        var _this;

        var _ref$xmlns = _ref.xmlns,
            xmlns = _ref$xmlns === void 0 ? 'http://schemas.openxmlformats.org/spreadsheetml/2006/main' : _ref$xmlns;

        classCallCheck(this, Xsst);

        _this = possibleConstructorReturn(this, getPrototypeOf(Xsst).call(this, {
          xmlns: xmlns
        }, children));

        _initialize(assertThisInitialized(_this));

        _this[HEAD] = '<?xml version="1.0" encoding="UTF-8"?>';
        return _this;
      }

      return Xsst;
    }(_Node);

    return {
      F: Xsst,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "sst";
        }
      }]
    };
  }, Node);
  var Xsi =
  /*#__PURE__*/
  function (_Node3) {
    inherits(Xsi, _Node3);

    function Xsi() {
      var _getPrototypeOf2;

      var _this2;

      classCallCheck(this, Xsi);

      for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }

      _this2 = possibleConstructorReturn(this, (_getPrototypeOf2 = getPrototypeOf(Xsi)).call.apply(_getPrototypeOf2, [this].concat(args)));

      defineProperty(assertThisInitialized(_this2), "__name", "si");

      return _this2;
    }

    return Xsi;
  }(Node);
  var Xt = _decorate$2([props('xml:space')], function (_initialize2, _Node4) {
    var Xt =
    /*#__PURE__*/
    function (_Node5) {
      inherits(Xt, _Node5);

      function Xt() {
        var _getPrototypeOf3;

        var _this3;

        classCallCheck(this, Xt);

        for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
          args[_key2] = arguments[_key2];
        }

        _this3 = possibleConstructorReturn(this, (_getPrototypeOf3 = getPrototypeOf(Xt)).call.apply(_getPrototypeOf3, [this].concat(args)));

        _initialize2(assertThisInitialized(_this3));

        return _this3;
      }

      return Xt;
    }(_Node4);

    return {
      F: Xt,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "t";
        }
      }]
    };
  }, Node);

  var RefTable =
  /*#__PURE__*/
  function () {
    function RefTable() {
      classCallCheck(this, RefTable);

      this.strings = [];
      this.known = {};
    }

    createClass(RefTable, [{
      key: "makeXsst",
      value: function makeXsst() {
        var len = this.strings.length;
        var sst = new Xsst({
          count: len,
          uniqueCount: len
        });
        var _iteratorNormalCompletion = true;
        var _didIteratorError = false;
        var _iteratorError = undefined;

        try {
          for (var _iterator = this.strings[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
            var str = _step.value;
            var si = new Xsi({}, [new Xt({}, [str])]);
            sst.children.push(si);
          }
        } catch (err) {
          _didIteratorError = true;
          _iteratorError = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion && _iterator["return"] != null) {
              _iterator["return"]();
            }
          } finally {
            if (_didIteratorError) {
              throw _iteratorError;
            }
          }
        }

        return sst;
      }
    }, {
      key: "addString",
      value: function addString(str) {
        if (this.known[str] === undefined) {
          var index = this.strings.length;
          this.strings.push(str);
          this.known[str] = index;
          return index;
        }

        return this.known[str];
      }
    }, {
      key: "getString",
      value: function getString(index) {
        return this.strings[index];
      }
    }, {
      key: "length",
      value: function length() {
        return this.strings.length;
      }
    }]);

    return RefTable;
  }();

  function _decorate$3(decorators, factory, superClass, mixins) { var api = _getDecoratorsApi$3(); if (mixins) { for (var i = 0; i < mixins.length; i++) { api = mixins[i](api); } } var r = factory(function initialize(O) { api.initializeInstanceElements(O, decorated.elements); }, superClass); var decorated = api.decorateClass(_coalesceClassElements$3(r.d.map(_createElementDescriptor$3)), decorators); api.initializeClassElements(r.F, decorated.elements); return api.runClassFinishers(r.F, decorated.finishers); }

  function _getDecoratorsApi$3() { _getDecoratorsApi$3 = function _getDecoratorsApi() { return api; }; var api = { elementsDefinitionOrder: [["method"], ["field"]], initializeInstanceElements: function initializeInstanceElements(O, elements) { ["method", "field"].forEach(function (kind) { elements.forEach(function (element) { if (element.kind === kind && element.placement === "own") { this.defineClassElement(O, element); } }, this); }, this); }, initializeClassElements: function initializeClassElements(F, elements) { var proto = F.prototype; ["method", "field"].forEach(function (kind) { elements.forEach(function (element) { var placement = element.placement; if (element.kind === kind && (placement === "static" || placement === "prototype")) { var receiver = placement === "static" ? F : proto; this.defineClassElement(receiver, element); } }, this); }, this); }, defineClassElement: function defineClassElement(receiver, element) { var descriptor = element.descriptor; if (element.kind === "field") { var initializer = element.initializer; descriptor = { enumerable: descriptor.enumerable, writable: descriptor.writable, configurable: descriptor.configurable, value: initializer === void 0 ? void 0 : initializer.call(receiver) }; } Object.defineProperty(receiver, element.key, descriptor); }, decorateClass: function decorateClass(elements, decorators) { var newElements = []; var finishers = []; var placements = { "static": [], prototype: [], own: [] }; elements.forEach(function (element) { this.addElementPlacement(element, placements); }, this); elements.forEach(function (element) { if (!_hasDecorators$3(element)) return newElements.push(element); var elementFinishersExtras = this.decorateElement(element, placements); newElements.push(elementFinishersExtras.element); newElements.push.apply(newElements, elementFinishersExtras.extras); finishers.push.apply(finishers, elementFinishersExtras.finishers); }, this); if (!decorators) { return { elements: newElements, finishers: finishers }; } var result = this.decorateConstructor(newElements, decorators); finishers.push.apply(finishers, result.finishers); result.finishers = finishers; return result; }, addElementPlacement: function addElementPlacement(element, placements, silent) { var keys = placements[element.placement]; if (!silent && keys.indexOf(element.key) !== -1) { throw new TypeError("Duplicated element (" + element.key + ")"); } keys.push(element.key); }, decorateElement: function decorateElement(element, placements) { var extras = []; var finishers = []; for (var decorators = element.decorators, i = decorators.length - 1; i >= 0; i--) { var keys = placements[element.placement]; keys.splice(keys.indexOf(element.key), 1); var elementObject = this.fromElementDescriptor(element); var elementFinisherExtras = this.toElementFinisherExtras((0, decorators[i])(elementObject) || elementObject); element = elementFinisherExtras.element; this.addElementPlacement(element, placements); if (elementFinisherExtras.finisher) { finishers.push(elementFinisherExtras.finisher); } var newExtras = elementFinisherExtras.extras; if (newExtras) { for (var j = 0; j < newExtras.length; j++) { this.addElementPlacement(newExtras[j], placements); } extras.push.apply(extras, newExtras); } } return { element: element, finishers: finishers, extras: extras }; }, decorateConstructor: function decorateConstructor(elements, decorators) { var finishers = []; for (var i = decorators.length - 1; i >= 0; i--) { var obj = this.fromClassDescriptor(elements); var elementsAndFinisher = this.toClassDescriptor((0, decorators[i])(obj) || obj); if (elementsAndFinisher.finisher !== undefined) { finishers.push(elementsAndFinisher.finisher); } if (elementsAndFinisher.elements !== undefined) { elements = elementsAndFinisher.elements; for (var j = 0; j < elements.length - 1; j++) { for (var k = j + 1; k < elements.length; k++) { if (elements[j].key === elements[k].key && elements[j].placement === elements[k].placement) { throw new TypeError("Duplicated element (" + elements[j].key + ")"); } } } } } return { elements: elements, finishers: finishers }; }, fromElementDescriptor: function fromElementDescriptor(element) { var obj = { kind: element.kind, key: element.key, placement: element.placement, descriptor: element.descriptor }; var desc = { value: "Descriptor", configurable: true }; Object.defineProperty(obj, Symbol.toStringTag, desc); if (element.kind === "field") obj.initializer = element.initializer; return obj; }, toElementDescriptors: function toElementDescriptors(elementObjects) { if (elementObjects === undefined) return; return toArray(elementObjects).map(function (elementObject) { var element = this.toElementDescriptor(elementObject); this.disallowProperty(elementObject, "finisher", "An element descriptor"); this.disallowProperty(elementObject, "extras", "An element descriptor"); return element; }, this); }, toElementDescriptor: function toElementDescriptor(elementObject) { var kind = String(elementObject.kind); if (kind !== "method" && kind !== "field") { throw new TypeError('An element descriptor\'s .kind property must be either "method" or' + ' "field", but a decorator created an element descriptor with' + ' .kind "' + kind + '"'); } var key = _toPropertyKey$3(elementObject.key); var placement = String(elementObject.placement); if (placement !== "static" && placement !== "prototype" && placement !== "own") { throw new TypeError('An element descriptor\'s .placement property must be one of "static",' + ' "prototype" or "own", but a decorator created an element descriptor' + ' with .placement "' + placement + '"'); } var descriptor = elementObject.descriptor; this.disallowProperty(elementObject, "elements", "An element descriptor"); var element = { kind: kind, key: key, placement: placement, descriptor: Object.assign({}, descriptor) }; if (kind !== "field") { this.disallowProperty(elementObject, "initializer", "A method descriptor"); } else { this.disallowProperty(descriptor, "get", "The property descriptor of a field descriptor"); this.disallowProperty(descriptor, "set", "The property descriptor of a field descriptor"); this.disallowProperty(descriptor, "value", "The property descriptor of a field descriptor"); element.initializer = elementObject.initializer; } return element; }, toElementFinisherExtras: function toElementFinisherExtras(elementObject) { var element = this.toElementDescriptor(elementObject); var finisher = _optionalCallableProperty$3(elementObject, "finisher"); var extras = this.toElementDescriptors(elementObject.extras); return { element: element, finisher: finisher, extras: extras }; }, fromClassDescriptor: function fromClassDescriptor(elements) { var obj = { kind: "class", elements: elements.map(this.fromElementDescriptor, this) }; var desc = { value: "Descriptor", configurable: true }; Object.defineProperty(obj, Symbol.toStringTag, desc); return obj; }, toClassDescriptor: function toClassDescriptor(obj) { var kind = String(obj.kind); if (kind !== "class") { throw new TypeError('A class descriptor\'s .kind property must be "class", but a decorator' + ' created a class descriptor with .kind "' + kind + '"'); } this.disallowProperty(obj, "key", "A class descriptor"); this.disallowProperty(obj, "placement", "A class descriptor"); this.disallowProperty(obj, "descriptor", "A class descriptor"); this.disallowProperty(obj, "initializer", "A class descriptor"); this.disallowProperty(obj, "extras", "A class descriptor"); var finisher = _optionalCallableProperty$3(obj, "finisher"); var elements = this.toElementDescriptors(obj.elements); return { elements: elements, finisher: finisher }; }, runClassFinishers: function runClassFinishers(constructor, finishers) { for (var i = 0; i < finishers.length; i++) { var newConstructor = (0, finishers[i])(constructor); if (newConstructor !== undefined) { if (typeof newConstructor !== "function") { throw new TypeError("Finishers must return a constructor."); } constructor = newConstructor; } } return constructor; }, disallowProperty: function disallowProperty(obj, name, objectType) { if (obj[name] !== undefined) { throw new TypeError(objectType + " can't have a ." + name + " property."); } } }; return api; }

  function _createElementDescriptor$3(def) { var key = _toPropertyKey$3(def.key); var descriptor; if (def.kind === "method") { descriptor = { value: def.value, writable: true, configurable: true, enumerable: false }; } else if (def.kind === "get") { descriptor = { get: def.value, configurable: true, enumerable: false }; } else if (def.kind === "set") { descriptor = { set: def.value, configurable: true, enumerable: false }; } else if (def.kind === "field") { descriptor = { configurable: true, writable: true, enumerable: true }; } var element = { kind: def.kind === "field" ? "field" : "method", key: key, placement: def["static"] ? "static" : def.kind === "field" ? "own" : "prototype", descriptor: descriptor }; if (def.decorators) element.decorators = def.decorators; if (def.kind === "field") element.initializer = def.value; return element; }

  function _coalesceGetterSetter$3(element, other) { if (element.descriptor.get !== undefined) { other.descriptor.get = element.descriptor.get; } else { other.descriptor.set = element.descriptor.set; } }

  function _coalesceClassElements$3(elements) { var newElements = []; var isSameElement = function isSameElement(other) { return other.kind === "method" && other.key === element.key && other.placement === element.placement; }; for (var i = 0; i < elements.length; i++) { var element = elements[i]; var other; if (element.kind === "method" && (other = newElements.find(isSameElement))) { if (_isDataDescriptor$3(element.descriptor) || _isDataDescriptor$3(other.descriptor)) { if (_hasDecorators$3(element) || _hasDecorators$3(other)) { throw new ReferenceError("Duplicated methods (" + element.key + ") can't be decorated."); } other.descriptor = element.descriptor; } else { if (_hasDecorators$3(element)) { if (_hasDecorators$3(other)) { throw new ReferenceError("Decorators can't be placed on different accessors with for " + "the same property (" + element.key + ")."); } other.decorators = element.decorators; } _coalesceGetterSetter$3(element, other); } } else { newElements.push(element); } } return newElements; }

  function _hasDecorators$3(element) { return element.decorators && element.decorators.length; }

  function _isDataDescriptor$3(desc) { return desc !== undefined && !(desc.value === undefined && desc.writable === undefined); }

  function _optionalCallableProperty$3(obj, name) { var value = obj[name]; if (value !== undefined && typeof value !== "function") { throw new TypeError("Expected '" + name + "' to be a function"); } return value; }

  function _toPropertyKey$3(arg) { var key = _toPrimitive$3(arg, "string"); return _typeof_1(key) === "symbol" ? key : String(key); }

  function _toPrimitive$3(input, hint) { if (_typeof_1(input) !== "object" || input === null) return input; var prim = input[Symbol.toPrimitive]; if (prim !== undefined) { var res = prim.call(input, hint || "default"); if (_typeof_1(res) !== "object") return res; throw new TypeError("@@toPrimitive must return a primitive value."); } return (hint === "string" ? String : Number)(input); }
  var XRelationships = _decorate$3([props('xmlns')], function (_initialize, _Node) {
    var XRelationships =
    /*#__PURE__*/
    function (_Node2) {
      inherits(XRelationships, _Node2);

      function XRelationships(_ref, children) {
        var _this;

        var _ref$xmlns = _ref.xmlns,
            xmlns = _ref$xmlns === void 0 ? 'http://schemas.openxmlformats.org/package/2006/relationships' : _ref$xmlns;

        classCallCheck(this, XRelationships);

        _this = possibleConstructorReturn(this, getPrototypeOf(XRelationships).call(this, {
          xmlns: xmlns
        }, children));

        _initialize(assertThisInitialized(_this));

        _this[HEAD] = '<?xml version="1.0" encoding="UTF-8"?>';
        return _this;
      }

      return XRelationships;
    }(_Node);

    return {
      F: XRelationships,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "Relationships";
        }
      }]
    };
  }, Node);
  var XRelationship = _decorate$3([props('Id', 'Target', 'Type')], function (_initialize2, _Node3) {
    var XRelationship =
    /*#__PURE__*/
    function (_Node4) {
      inherits(XRelationship, _Node4);

      function XRelationship() {
        var _getPrototypeOf2;

        var _this2;

        classCallCheck(this, XRelationship);

        for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
          args[_key] = arguments[_key];
        }

        _this2 = possibleConstructorReturn(this, (_getPrototypeOf2 = getPrototypeOf(XRelationship)).call.apply(_getPrototypeOf2, [this].concat(args)));

        _initialize2(assertThisInitialized(_this2));

        return _this2;
      }

      return XRelationship;
    }(_Node3);

    return {
      F: XRelationship,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "Relationship";
        }
      }]
    };
  }, Node);
  var Xworkbook = _decorate$3([props('xmlns', 'xmlns:r')], function (_initialize3, _Node5) {
    var Xworkbook =
    /*#__PURE__*/
    function (_Node6) {
      inherits(Xworkbook, _Node6);

      function Xworkbook() {
        var _this3;

        var attrs = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};
        var children = arguments.length > 1 ? arguments[1] : undefined;

        classCallCheck(this, Xworkbook);

        attrs['xmlns'] = attrs['xmlns'] || 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
        attrs['xmlns:r'] = attrs['xmlns:r'] || 'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
        _this3 = possibleConstructorReturn(this, getPrototypeOf(Xworkbook).call(this, attrs, children));

        _initialize3(assertThisInitialized(_this3));

        _this3[HEAD] = '<?xml version="1.0" encoding="UTF-8"?>';
        return _this3;
      }

      return Xworkbook;
    }(_Node5);

    return {
      F: Xworkbook,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "workbook";
        }
      }, {
        kind: "field",
        key: "fileVersion",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "workbookPr",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "bookViews",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "sheets",
        value: function value() {
          return null;
        }
      }, {
        kind: "field",
        key: "calcPr",
        value: function value() {
          return null;
        }
      }, {
        kind: "method",
        key: "render",
        value: function render() {
          this.children = [];
          if (this.fileVersion) this.children.push(this.fileVersion);
          if (this.workbookPr) this.children.push(this.workbookPr);
          if (this.bookViews) this.children.push(this.bookViews);
          if (this.sheets) this.children.push(this.sheets);
          if (this.calcPr) this.children.push(this.calcPr);
          return get(getPrototypeOf(Xworkbook.prototype), "render", this).call(this);
        }
      }]
    };
  }, Node);
  var XfileVersion = _decorate$3([props('appName', 'lastEdited', 'lowestEdited', 'rupBuild')], function (_initialize4, _Node7) {
    var XfileVersion =
    /*#__PURE__*/
    function (_Node8) {
      inherits(XfileVersion, _Node8);

      function XfileVersion() {
        var _getPrototypeOf3;

        var _this4;

        classCallCheck(this, XfileVersion);

        for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
          args[_key2] = arguments[_key2];
        }

        _this4 = possibleConstructorReturn(this, (_getPrototypeOf3 = getPrototypeOf(XfileVersion)).call.apply(_getPrototypeOf3, [this].concat(args)));

        _initialize4(assertThisInitialized(_this4));

        return _this4;
      }

      return XfileVersion;
    }(_Node7);

    return {
      F: XfileVersion,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "fileVersion";
        }
      }]
    };
  }, Node);
  var XworkbookPr = _decorate$3([props('defaultThemeVersion', 'backupFile', 'showObjects', 'date1904')], function (_initialize5, _Node9) {
    var XworkbookPr =
    /*#__PURE__*/
    function (_Node10) {
      inherits(XworkbookPr, _Node10);

      function XworkbookPr() {
        var _getPrototypeOf4;

        var _this5;

        classCallCheck(this, XworkbookPr);

        for (var _len3 = arguments.length, args = new Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
          args[_key3] = arguments[_key3];
        }

        _this5 = possibleConstructorReturn(this, (_getPrototypeOf4 = getPrototypeOf(XworkbookPr)).call.apply(_getPrototypeOf4, [this].concat(args)));

        _initialize5(assertThisInitialized(_this5));

        return _this5;
      }

      return XworkbookPr;
    }(_Node9);

    return {
      F: XworkbookPr,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "workbookPr";
        }
      }]
    };
  }, Node);
  var XbookViews =
  /*#__PURE__*/
  function (_Node12) {
    inherits(XbookViews, _Node12);

    function XbookViews() {
      var _getPrototypeOf6;

      var _this7;

      classCallCheck(this, XbookViews);

      for (var _len5 = arguments.length, args = new Array(_len5), _key5 = 0; _key5 < _len5; _key5++) {
        args[_key5] = arguments[_key5];
      }

      _this7 = possibleConstructorReturn(this, (_getPrototypeOf6 = getPrototypeOf(XbookViews)).call.apply(_getPrototypeOf6, [this].concat(args)));

      defineProperty(assertThisInitialized(_this7), "__name", "bookViews");

      return _this7;
    }

    return XbookViews;
  }(Node);
  var XworkbookView = _decorate$3([props('activeTab', 'firstSheet', 'showHorizontalScroll', 'showVerticalScroll', 'showSheetTabs', 'tabRatio', 'windowHeight', 'windowWidth', 'xWindow', 'yWindow')], function (_initialize6, _Node13) {
    var XworkbookView =
    /*#__PURE__*/
    function (_Node14) {
      inherits(XworkbookView, _Node14);

      function XworkbookView() {
        var _getPrototypeOf7;

        var _this8;

        classCallCheck(this, XworkbookView);

        for (var _len6 = arguments.length, args = new Array(_len6), _key6 = 0; _key6 < _len6; _key6++) {
          args[_key6] = arguments[_key6];
        }

        _this8 = possibleConstructorReturn(this, (_getPrototypeOf7 = getPrototypeOf(XworkbookView)).call.apply(_getPrototypeOf7, [this].concat(args)));

        _initialize6(assertThisInitialized(_this8));

        return _this8;
      }

      return XworkbookView;
    }(_Node13);

    return {
      F: XworkbookView,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "workbookView";
        }
      }]
    };
  }, Node);
  var Xsheets =
  /*#__PURE__*/
  function (_Node15) {
    inherits(Xsheets, _Node15);

    function Xsheets() {
      var _getPrototypeOf8;

      var _this9;

      classCallCheck(this, Xsheets);

      for (var _len7 = arguments.length, args = new Array(_len7), _key7 = 0; _key7 < _len7; _key7++) {
        args[_key7] = arguments[_key7];
      }

      _this9 = possibleConstructorReturn(this, (_getPrototypeOf8 = getPrototypeOf(Xsheets)).call.apply(_getPrototypeOf8, [this].concat(args)));

      defineProperty(assertThisInitialized(_this9), "__name", "sheets");

      return _this9;
    }

    return Xsheets;
  }(Node);
  var Xsheet = _decorate$3([props('name', 'sheetId', 'r:id', 'state')], function (_initialize7, _Node16) {
    var Xsheet =
    /*#__PURE__*/
    function (_Node17) {
      inherits(Xsheet, _Node17);

      function Xsheet() {
        var _getPrototypeOf9;

        var _this10;

        classCallCheck(this, Xsheet);

        for (var _len8 = arguments.length, args = new Array(_len8), _key8 = 0; _key8 < _len8; _key8++) {
          args[_key8] = arguments[_key8];
        }

        _this10 = possibleConstructorReturn(this, (_getPrototypeOf9 = getPrototypeOf(Xsheet)).call.apply(_getPrototypeOf9, [this].concat(args)));

        _initialize7(assertThisInitialized(_this10));

        return _this10;
      }

      return Xsheet;
    }(_Node16);

    return {
      F: Xsheet,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "sheet";
        }
      }]
    };
  }, Node);
  var XcalcPr = _decorate$3([props('calcId', 'iterateCount', 'refMode', 'iterate', 'iterateDelta')], function (_initialize8, _Node18) {
    var XcalcPr =
    /*#__PURE__*/
    function (_Node19) {
      inherits(XcalcPr, _Node19);

      function XcalcPr() {
        var _getPrototypeOf10;

        var _this11;

        classCallCheck(this, XcalcPr);

        for (var _len9 = arguments.length, args = new Array(_len9), _key9 = 0; _key9 < _len9; _key9++) {
          args[_key9] = arguments[_key9];
        }

        _this11 = possibleConstructorReturn(this, (_getPrototypeOf10 = getPrototypeOf(XcalcPr)).call.apply(_getPrototypeOf10, [this].concat(args)));

        _initialize8(assertThisInitialized(_this11));

        return _this11;
      }

      return XcalcPr;
    }(_Node18);

    return {
      F: XcalcPr,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "calcPr";
        }
      }]
    };
  }, Node);
  function makeWorkbookRels(sheetCount) {
    var rels = new XRelationships({});

    for (var i = 1; i <= sheetCount; i++) {
      rels.children.push(new XRelationship({
        Id: "rId".concat(i),
        Target: "worksheets/sheet".concat(i, ".xml"),
        Type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet'
      }));
    }

    rels.children.push(new XRelationship({
      Id: "rId".concat(sheetCount + 1),
      Target: 'sharedStrings.xml',
      Type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings'
    }));
    rels.children.push(new XRelationship({
      Id: "rId".concat(sheetCount + 2),
      Target: 'theme/theme1.xml',
      Type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme'
    }));
    rels.children.push(new XRelationship({
      Id: "rId".concat(sheetCount + 3),
      Target: 'styles.xml',
      Type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles'
    }));
    return rels;
  }
  function makeXworkbook() {
    var workbook = new Xworkbook();
    workbook.fileVersion = new XfileVersion({
      appName: 'JS XLSX'
    });
    workbook.workbookPr = new XworkbookPr({
      showObjects: 'all'
    });
    workbook.bookViews = new XbookViews({}, [new XworkbookView({
      showHorizontalScroll: true,
      showSheetTabs: true,
      showVerticalScroll: true,
      tabRatio: 204,
      windowHeight: 8192,
      windowWidth: 16384,
      xWindow: 0,
      yWindow: 0
    })]);
    workbook.calcPr = new XcalcPr({
      iterateCount: 100,
      iterate: false,
      iterateDelta: 0.001,
      refMode: 'A1'
    });
    return workbook;
  }

  function _decorate$4(decorators, factory, superClass, mixins) { var api = _getDecoratorsApi$4(); if (mixins) { for (var i = 0; i < mixins.length; i++) { api = mixins[i](api); } } var r = factory(function initialize(O) { api.initializeInstanceElements(O, decorated.elements); }, superClass); var decorated = api.decorateClass(_coalesceClassElements$4(r.d.map(_createElementDescriptor$4)), decorators); api.initializeClassElements(r.F, decorated.elements); return api.runClassFinishers(r.F, decorated.finishers); }

  function _getDecoratorsApi$4() { _getDecoratorsApi$4 = function _getDecoratorsApi() { return api; }; var api = { elementsDefinitionOrder: [["method"], ["field"]], initializeInstanceElements: function initializeInstanceElements(O, elements) { ["method", "field"].forEach(function (kind) { elements.forEach(function (element) { if (element.kind === kind && element.placement === "own") { this.defineClassElement(O, element); } }, this); }, this); }, initializeClassElements: function initializeClassElements(F, elements) { var proto = F.prototype; ["method", "field"].forEach(function (kind) { elements.forEach(function (element) { var placement = element.placement; if (element.kind === kind && (placement === "static" || placement === "prototype")) { var receiver = placement === "static" ? F : proto; this.defineClassElement(receiver, element); } }, this); }, this); }, defineClassElement: function defineClassElement(receiver, element) { var descriptor = element.descriptor; if (element.kind === "field") { var initializer = element.initializer; descriptor = { enumerable: descriptor.enumerable, writable: descriptor.writable, configurable: descriptor.configurable, value: initializer === void 0 ? void 0 : initializer.call(receiver) }; } Object.defineProperty(receiver, element.key, descriptor); }, decorateClass: function decorateClass(elements, decorators) { var newElements = []; var finishers = []; var placements = { "static": [], prototype: [], own: [] }; elements.forEach(function (element) { this.addElementPlacement(element, placements); }, this); elements.forEach(function (element) { if (!_hasDecorators$4(element)) return newElements.push(element); var elementFinishersExtras = this.decorateElement(element, placements); newElements.push(elementFinishersExtras.element); newElements.push.apply(newElements, elementFinishersExtras.extras); finishers.push.apply(finishers, elementFinishersExtras.finishers); }, this); if (!decorators) { return { elements: newElements, finishers: finishers }; } var result = this.decorateConstructor(newElements, decorators); finishers.push.apply(finishers, result.finishers); result.finishers = finishers; return result; }, addElementPlacement: function addElementPlacement(element, placements, silent) { var keys = placements[element.placement]; if (!silent && keys.indexOf(element.key) !== -1) { throw new TypeError("Duplicated element (" + element.key + ")"); } keys.push(element.key); }, decorateElement: function decorateElement(element, placements) { var extras = []; var finishers = []; for (var decorators = element.decorators, i = decorators.length - 1; i >= 0; i--) { var keys = placements[element.placement]; keys.splice(keys.indexOf(element.key), 1); var elementObject = this.fromElementDescriptor(element); var elementFinisherExtras = this.toElementFinisherExtras((0, decorators[i])(elementObject) || elementObject); element = elementFinisherExtras.element; this.addElementPlacement(element, placements); if (elementFinisherExtras.finisher) { finishers.push(elementFinisherExtras.finisher); } var newExtras = elementFinisherExtras.extras; if (newExtras) { for (var j = 0; j < newExtras.length; j++) { this.addElementPlacement(newExtras[j], placements); } extras.push.apply(extras, newExtras); } } return { element: element, finishers: finishers, extras: extras }; }, decorateConstructor: function decorateConstructor(elements, decorators) { var finishers = []; for (var i = decorators.length - 1; i >= 0; i--) { var obj = this.fromClassDescriptor(elements); var elementsAndFinisher = this.toClassDescriptor((0, decorators[i])(obj) || obj); if (elementsAndFinisher.finisher !== undefined) { finishers.push(elementsAndFinisher.finisher); } if (elementsAndFinisher.elements !== undefined) { elements = elementsAndFinisher.elements; for (var j = 0; j < elements.length - 1; j++) { for (var k = j + 1; k < elements.length; k++) { if (elements[j].key === elements[k].key && elements[j].placement === elements[k].placement) { throw new TypeError("Duplicated element (" + elements[j].key + ")"); } } } } } return { elements: elements, finishers: finishers }; }, fromElementDescriptor: function fromElementDescriptor(element) { var obj = { kind: element.kind, key: element.key, placement: element.placement, descriptor: element.descriptor }; var desc = { value: "Descriptor", configurable: true }; Object.defineProperty(obj, Symbol.toStringTag, desc); if (element.kind === "field") obj.initializer = element.initializer; return obj; }, toElementDescriptors: function toElementDescriptors(elementObjects) { if (elementObjects === undefined) return; return toArray(elementObjects).map(function (elementObject) { var element = this.toElementDescriptor(elementObject); this.disallowProperty(elementObject, "finisher", "An element descriptor"); this.disallowProperty(elementObject, "extras", "An element descriptor"); return element; }, this); }, toElementDescriptor: function toElementDescriptor(elementObject) { var kind = String(elementObject.kind); if (kind !== "method" && kind !== "field") { throw new TypeError('An element descriptor\'s .kind property must be either "method" or' + ' "field", but a decorator created an element descriptor with' + ' .kind "' + kind + '"'); } var key = _toPropertyKey$4(elementObject.key); var placement = String(elementObject.placement); if (placement !== "static" && placement !== "prototype" && placement !== "own") { throw new TypeError('An element descriptor\'s .placement property must be one of "static",' + ' "prototype" or "own", but a decorator created an element descriptor' + ' with .placement "' + placement + '"'); } var descriptor = elementObject.descriptor; this.disallowProperty(elementObject, "elements", "An element descriptor"); var element = { kind: kind, key: key, placement: placement, descriptor: Object.assign({}, descriptor) }; if (kind !== "field") { this.disallowProperty(elementObject, "initializer", "A method descriptor"); } else { this.disallowProperty(descriptor, "get", "The property descriptor of a field descriptor"); this.disallowProperty(descriptor, "set", "The property descriptor of a field descriptor"); this.disallowProperty(descriptor, "value", "The property descriptor of a field descriptor"); element.initializer = elementObject.initializer; } return element; }, toElementFinisherExtras: function toElementFinisherExtras(elementObject) { var element = this.toElementDescriptor(elementObject); var finisher = _optionalCallableProperty$4(elementObject, "finisher"); var extras = this.toElementDescriptors(elementObject.extras); return { element: element, finisher: finisher, extras: extras }; }, fromClassDescriptor: function fromClassDescriptor(elements) { var obj = { kind: "class", elements: elements.map(this.fromElementDescriptor, this) }; var desc = { value: "Descriptor", configurable: true }; Object.defineProperty(obj, Symbol.toStringTag, desc); return obj; }, toClassDescriptor: function toClassDescriptor(obj) { var kind = String(obj.kind); if (kind !== "class") { throw new TypeError('A class descriptor\'s .kind property must be "class", but a decorator' + ' created a class descriptor with .kind "' + kind + '"'); } this.disallowProperty(obj, "key", "A class descriptor"); this.disallowProperty(obj, "placement", "A class descriptor"); this.disallowProperty(obj, "descriptor", "A class descriptor"); this.disallowProperty(obj, "initializer", "A class descriptor"); this.disallowProperty(obj, "extras", "A class descriptor"); var finisher = _optionalCallableProperty$4(obj, "finisher"); var elements = this.toElementDescriptors(obj.elements); return { elements: elements, finisher: finisher }; }, runClassFinishers: function runClassFinishers(constructor, finishers) { for (var i = 0; i < finishers.length; i++) { var newConstructor = (0, finishers[i])(constructor); if (newConstructor !== undefined) { if (typeof newConstructor !== "function") { throw new TypeError("Finishers must return a constructor."); } constructor = newConstructor; } } return constructor; }, disallowProperty: function disallowProperty(obj, name, objectType) { if (obj[name] !== undefined) { throw new TypeError(objectType + " can't have a ." + name + " property."); } } }; return api; }

  function _createElementDescriptor$4(def) { var key = _toPropertyKey$4(def.key); var descriptor; if (def.kind === "method") { descriptor = { value: def.value, writable: true, configurable: true, enumerable: false }; } else if (def.kind === "get") { descriptor = { get: def.value, configurable: true, enumerable: false }; } else if (def.kind === "set") { descriptor = { set: def.value, configurable: true, enumerable: false }; } else if (def.kind === "field") { descriptor = { configurable: true, writable: true, enumerable: true }; } var element = { kind: def.kind === "field" ? "field" : "method", key: key, placement: def["static"] ? "static" : def.kind === "field" ? "own" : "prototype", descriptor: descriptor }; if (def.decorators) element.decorators = def.decorators; if (def.kind === "field") element.initializer = def.value; return element; }

  function _coalesceGetterSetter$4(element, other) { if (element.descriptor.get !== undefined) { other.descriptor.get = element.descriptor.get; } else { other.descriptor.set = element.descriptor.set; } }

  function _coalesceClassElements$4(elements) { var newElements = []; var isSameElement = function isSameElement(other) { return other.kind === "method" && other.key === element.key && other.placement === element.placement; }; for (var i = 0; i < elements.length; i++) { var element = elements[i]; var other; if (element.kind === "method" && (other = newElements.find(isSameElement))) { if (_isDataDescriptor$4(element.descriptor) || _isDataDescriptor$4(other.descriptor)) { if (_hasDecorators$4(element) || _hasDecorators$4(other)) { throw new ReferenceError("Duplicated methods (" + element.key + ") can't be decorated."); } other.descriptor = element.descriptor; } else { if (_hasDecorators$4(element)) { if (_hasDecorators$4(other)) { throw new ReferenceError("Decorators can't be placed on different accessors with for " + "the same property (" + element.key + ")."); } other.decorators = element.decorators; } _coalesceGetterSetter$4(element, other); } } else { newElements.push(element); } } return newElements; }

  function _hasDecorators$4(element) { return element.decorators && element.decorators.length; }

  function _isDataDescriptor$4(desc) { return desc !== undefined && !(desc.value === undefined && desc.writable === undefined); }

  function _optionalCallableProperty$4(obj, name) { var value = obj[name]; if (value !== undefined && typeof value !== "function") { throw new TypeError("Expected '" + name + "' to be a function"); } return value; }

  function _toPropertyKey$4(arg) { var key = _toPrimitive$4(arg, "string"); return _typeof_1(key) === "symbol" ? key : String(key); }

  function _toPrimitive$4(input, hint) { if (_typeof_1(input) !== "object" || input === null) return input; var prim = input[Symbol.toPrimitive]; if (prim !== undefined) { var res = prim.call(input, hint || "default"); if (_typeof_1(res) !== "object") return res; throw new TypeError("@@toPrimitive must return a primitive value."); } return (hint === "string" ? String : Number)(input); }
  var XTypes = _decorate$4([props('xmlns')], function (_initialize, _Node) {
    var XTypes =
    /*#__PURE__*/
    function (_Node2) {
      inherits(XTypes, _Node2);

      function XTypes(_ref, children) {
        var _this;

        var _ref$xmlns = _ref.xmlns,
            xmlns = _ref$xmlns === void 0 ? 'http://schemas.openxmlformats.org/package/2006/content-types' : _ref$xmlns;

        classCallCheck(this, XTypes);

        _this = possibleConstructorReturn(this, getPrototypeOf(XTypes).call(this, {
          xmlns: xmlns
        }, children));

        _initialize(assertThisInitialized(_this));

        _this[HEAD] = '<?xml version="1.0" encoding="UTF-8"?>';
        return _this;
      }

      return XTypes;
    }(_Node);

    return {
      F: XTypes,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "Types";
        }
      }]
    };
  }, Node);
  var XDefault = _decorate$4([props('Extension', 'ContentType')], function (_initialize2, _Node3) {
    var XDefault =
    /*#__PURE__*/
    function (_Node4) {
      inherits(XDefault, _Node4);

      function XDefault() {
        var _getPrototypeOf2;

        var _this2;

        classCallCheck(this, XDefault);

        for (var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++) {
          args[_key] = arguments[_key];
        }

        _this2 = possibleConstructorReturn(this, (_getPrototypeOf2 = getPrototypeOf(XDefault)).call.apply(_getPrototypeOf2, [this].concat(args)));

        _initialize2(assertThisInitialized(_this2));

        return _this2;
      }

      return XDefault;
    }(_Node3);

    return {
      F: XDefault,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "Default";
        }
      }]
    };
  }, Node);
  var XOverride = _decorate$4([props('PartName', 'ContentType')], function (_initialize3, _Node5) {
    var XOverride =
    /*#__PURE__*/
    function (_Node6) {
      inherits(XOverride, _Node6);

      function XOverride() {
        var _getPrototypeOf3;

        var _this3;

        classCallCheck(this, XOverride);

        for (var _len2 = arguments.length, args = new Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
          args[_key2] = arguments[_key2];
        }

        _this3 = possibleConstructorReturn(this, (_getPrototypeOf3 = getPrototypeOf(XOverride)).call.apply(_getPrototypeOf3, [this].concat(args)));

        _initialize3(assertThisInitialized(_this3));

        return _this3;
      }

      return XOverride;
    }(_Node5);

    return {
      F: XOverride,
      d: [{
        kind: "field",
        key: "__name",
        value: function value() {
          return "Override";
        }
      }]
    };
  }, Node);
  function makeXTypes() {
    var types = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : new XTypes({});
    var defaults = [{
      Extension: 'rels',
      ContentType: 'application/vnd.openxmlformats-package.relationships+xml'
    }, {
      Extension: 'xml',
      ContentType: 'application/xml'
    }];

    for (var _i = 0, _defaults = defaults; _i < _defaults.length; _i++) {
      var item = _defaults[_i];
      types.children.push(new XDefault(item));
    }

    var overrides = [{
      PartName: '/_rels/.rels',
      ContentType: 'application/vnd.openxmlformats-package.relationships+xml'
    }, {
      PartName: '/docProps/app.xml',
      ContentType: 'application/vnd.openxmlformats-officedocument.extended-properties+xml'
    }, {
      PartName: '/docProps/core.xml',
      ContentType: 'application/vnd.openxmlformats-package.core-properties+xml'
    }, {
      PartName: '/xl/_rels/workbook.xml.rels',
      ContentType: 'application/vnd.openxmlformats-package.relationships+xml'
    }, {
      PartName: '/xl/sharedStrings.xml',
      ContentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml'
    }, {
      PartName: '/xl/styles.xml',
      ContentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml'
    }, {
      PartName: '/xl/workbook.xml',
      ContentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml'
    }, {
      PartName: '/xl/theme/theme1.xml',
      ContentType: 'application/vnd.openxmlformats-officedocument.theme+xml'
    }];

    for (var _i2 = 0, _overrides = overrides; _i2 < _overrides.length; _i2++) {
      var override = _overrides[_i2];
      types.children.push(new XOverride(override));
    }

    return types;
  }

  /**
   * This is the main class, use it:
   *
   * ```js
   * import { File } from 'better-xlsx';
   * const file = new File();
   * const sheet = file.addSheet('Sheet-1');
   * ```
   *
   * @class File
   */

  var File =
  /*#__PURE__*/
  function () {
    /**
     * @private
     */

    /**
     * @private
     */

    /**
     * @private
     */
    function File() {
      classCallCheck(this, File);

      defineProperty(this, "sheet", {});

      defineProperty(this, "sheets", []);

      defineProperty(this, "definedNames", []);

      /**
       * @private
       */
      this.styles = new XstyleSheet({});
    }
    /**
     * Add a new Sheet, with the provided name, to a File
     * @param {String} name Name of the Sheet
     * @return {Sheet}
     */


    createClass(File, [{
      key: "addSheet",
      value: function addSheet(name) {
        if (this.sheet[name]) {
          throw new Error("duplicate sheet name ".concat(name, "."));
        }

        var sheet = new Sheet({
          name: name,
          file: this,
          selected: this.sheets.length === 0
        });
        this.sheet[name] = sheet;
        this.sheets.push(sheet);
        return sheet;
      }
      /**
       * Save the File to an xlsx file.
       * @param  {String} [type='nodebuffer'] For Node.js use `nodebuffer` and browser use `blob` or `base64`.
       * @param {Boolean} [compress=false] For file compression.
       * @return {Promise|stream} For Node.js return `stream` and browser return Promise.
       */

    }, {
      key: "saveAs",
      value: function saveAs() {
        var type = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 'nodebuffer';
        var compress = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : false;
        var parts = this.makeParts();
        var zip = new Zip();

        for (var _i = 0, _Object$keys = Object.keys(parts); _i < _Object$keys.length; _i++) {
          var key = _Object$keys[_i];
          zip.file(key, parts[key]);
        }

        var compression = compress ? 'DEFLATE' : 'STORE';

        if (type === 'blob' || type === 'base64') {
          return zip.generateAsync({
            type: type,
            compression: compression
          });
        } else {
          return zip.generateNodeStream({
            type: 'nodebuffer',
            compression: compression
          });
        }
      }
      /**
       * @private
       * @return {Object} XML files mapping object
       */

    }, {
      key: "makeParts",
      value: function makeParts() {
        var parts = {};
        var refTable = new RefTable();
        var types = makeXTypes();
        var workbook = makeXworkbook();
        this.styles.reset();
        var i = 1;
        var sheets = new Xsheets();
        var _iteratorNormalCompletion = true;
        var _didIteratorError = false;
        var _iteratorError = undefined;

        try {
          for (var _iterator = this.sheets[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
            var sheet = _step.value;
            var xSheet = sheet.makeXSheet(refTable, this.styles);
            types.children.push(new XOverride({
              PartName: "/xl/worksheets/sheet".concat(i, ".xml"),
              ContentType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml'
            }));
            sheets.children.push(new Xsheet({
              name: sheet.name,
              sheetId: i,
              'r:id': "rId".concat(i),
              state: 'visible'
            }));
            parts["xl/worksheets/sheet".concat(i, ".xml")] = xSheet.render();
            i++;
          }
        } catch (err) {
          _didIteratorError = true;
          _iteratorError = err;
        } finally {
          try {
            if (!_iteratorNormalCompletion && _iterator["return"] != null) {
              _iterator["return"]();
            }
          } finally {
            if (_didIteratorError) {
              throw _iteratorError;
            }
          }
        }

        workbook.sheets = sheets;
        parts['xl/workbook.xml'] = workbook.render();
        parts['_rels/.rels'] = DOT_RELS;
        parts['docProps/app.xml'] = DOCPROPS_APP;
        parts['docProps/core.xml'] = DOCPROPS_CORE;
        parts['xl/theme/theme1.xml'] = XL_THEME_THEME;
        parts['xl/sharedStrings.xml'] = refTable.makeXsst().render();
        parts['xl/_rels/workbook.xml.rels'] = makeWorkbookRels(this.sheets.length).render();
        parts['[Content_Types].xml'] = types.render();
        parts['xl/styles.xml'] = this.styles.render();
        return parts;
      }
    }]);

    return File;
  }();

  var file = /*#__PURE__*/Object.freeze({
    File: File
  });

  var index = objectSpread({}, cell, col, file, lib, row, sheet, style, {
    Zip: Zip
  });

  return index;

}));
