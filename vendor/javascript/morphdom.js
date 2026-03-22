// morphdom@2.7.8 downloaded from https://ga.jspm.io/npm:morphdom@2.7.8/dist/morphdom-esm.js

var e=11;function t(t,r){var a=r.attributes;var n;var i;var l;var o;var d;if(r.nodeType!==e&&t.nodeType!==e){for(var f=a.length-1;f>=0;f--){n=a[f];i=n.name;l=n.namespaceURI;o=n.value;if(l){i=n.localName||i;d=t.getAttributeNS(l,i);if(d!==o){n.prefix==="xmlns"&&(i=n.name);t.setAttributeNS(l,i,o)}}else{d=t.getAttribute(i);d!==o&&t.setAttribute(i,o)}}var u=t.attributes;for(var v=u.length-1;v>=0;v--){n=u[v];i=n.name;l=n.namespaceURI;if(l){i=n.localName||i;r.hasAttributeNS(l,i)||t.removeAttributeNS(l,i)}else r.hasAttribute(i)||t.removeAttribute(i)}}}var r;var a="http://www.w3.org/1999/xhtml";var n=typeof document==="undefined"?void 0:document;var i=!!n&&"content"in n.createElement("template");var l=!!n&&n.createRange&&"createContextualFragment"in n.createRange();function o(e){var t=n.createElement("template");t.innerHTML=e;return t.content.childNodes[0]}function d(e){if(!r){r=n.createRange();r.selectNode(n.body)}var t=r.createContextualFragment(e);return t.childNodes[0]}function f(e){var t=n.createElement("body");t.innerHTML=e;return t.childNodes[0]}
/**
 * This is about the same
 * var html = new DOMParser().parseFromString(str, 'text/html');
 * return html.body.firstChild;
 *
 * @method toElement
 * @param {String} str
 */function u(e){e=e.trim();return i?o(e):l?d(e):f(e)}
/**
 * Returns true if two node's names are the same.
 *
 * NOTE: We don't bother checking `namespaceURI` because you will never find two HTML elements with the same
 *       nodeName and different namespace URIs.
 *
 * @param {Element} a
 * @param {Element} b The target element
 * @return {boolean}
 */function v(e,t){var r=e.nodeName;var a=t.nodeName;var n,i;if(r===a)return true;n=r.charCodeAt(0);i=a.charCodeAt(0);return n<=90&&i>=97?r===a.toUpperCase():i<=90&&n>=97&&a===r.toUpperCase()}
/**
 * Create an element, optionally with a known namespace URI.
 *
 * @param {string} name the element name, e.g. 'div' or 'svg'
 * @param {string} [namespaceURI] the element's namespace URI, i.e. the value of
 * its `xmlns` attribute or its inferred namespace.
 *
 * @return {Element}
 */function s(e,t){return t&&t!==a?n.createElementNS(t,e):n.createElement(e)}function c(e,t){var r=e.firstChild;while(r){var a=r.nextSibling;t.appendChild(r);r=a}return t}function m(e,t,r){if(e[r]!==t[r]){e[r]=t[r];e[r]?e.setAttribute(r,""):e.removeAttribute(r)}}var h={OPTION:function(e,t){var r=e.parentNode;if(r){var a=r.nodeName.toUpperCase();if(a==="OPTGROUP"){r=r.parentNode;a=r&&r.nodeName.toUpperCase()}if(a==="SELECT"&&!r.hasAttribute("multiple")){if(e.hasAttribute("selected")&&!t.selected){e.setAttribute("selected","selected");e.removeAttribute("selected")}r.selectedIndex=-1}}m(e,t,"selected")},INPUT:function(e,t){m(e,t,"checked");m(e,t,"disabled");e.value!==t.value&&(e.value=t.value);t.hasAttribute("value")||e.removeAttribute("value")},TEXTAREA:function(e,t){var r=t.value;e.value!==r&&(e.value=r);var a=e.firstChild;if(a){var n=a.nodeValue;if(n==r||!r&&n==e.placeholder)return;a.nodeValue=r}},SELECT:function(e,t){if(!t.hasAttribute("multiple")){var r=-1;var a=0;var n=e.firstChild;var i;var l;while(n){l=n.nodeName&&n.nodeName.toUpperCase();if(l==="OPTGROUP"){i=n;n=i.firstChild;if(!n){n=i.nextSibling;i=null}}else{if(l==="OPTION"){if(n.hasAttribute("selected")){r=a;break}a++}n=n.nextSibling;if(!n&&i){n=i.nextSibling;i=null}}}e.selectedIndex=r}}};var p=1;var N=11;var b=3;var A=8;function C(){}function T(e){if(e)return e.getAttribute&&e.getAttribute("id")||e.id}function g(e){return function(t,r,a){a||(a={});if(typeof r==="string")if(t.nodeName==="#document"||t.nodeName==="HTML"){var i=r;r=n.createElement("html");r.innerHTML=i}else if(t.nodeName==="BODY"){var l=r;r=n.createElement("html");r.innerHTML=l;var o=r.querySelector("body");o&&(r=o)}else r=u(r);else r.nodeType===N&&(r=r.firstElementChild);var d=a.getNodeKey||T;var f=a.onBeforeNodeAdded||C;var m=a.onNodeAdded||C;var g=a.onBeforeElUpdated||C;var E=a.onElUpdated||C;var S=a.onBeforeNodeDiscarded||C;var x=a.onNodeDiscarded||C;var y=a.onBeforeElChildrenUpdated||C;var w=a.skipFromChildren||C;var U=a.addChild||function(e,t){return e.appendChild(t)};var O=a.childrenOnly===true;var R=Object.create(null);var V=[];function I(e){V.push(e)}function L(e,t){if(e.nodeType===p){var r=e.firstChild;while(r){var a=void 0;if(t&&(a=d(r)))I(a);else{x(r);r.firstChild&&L(r,t)}r=r.nextSibling}}}
/**
    * Removes a DOM node out of the original DOM
    *
    * @param  {Node} node The node to remove
    * @param  {Node} parentNode The nodes parent
    * @param  {Boolean} skipKeyedNodes If true then elements with keys will be skipped and not discarded.
    * @return {undefined}
    */function P(e,t,r){if(S(e)!==false){t&&t.removeChild(e);x(e);L(e,r)}}function B(e){if(e.nodeType===p||e.nodeType===N){var t=e.firstChild;while(t){var r=d(t);r&&(R[r]=t);B(t);t=t.nextSibling}}}B(t);function H(e){m(e);var t=e.firstChild;while(t){var r=t.nextSibling;var a=d(t);if(a){var n=R[a];if(n&&v(t,n)){t.parentNode.replaceChild(n,t);D(n,t)}else H(t)}else H(t);t=r}}function M(e,t,r){while(t){var a=t.nextSibling;(r=d(t))?I(r):P(t,e,true);t=a}}function D(t,r,a){var n=d(r);n&&delete R[n];if(!a){var i=g(t,r);if(i===false)return;if(i instanceof HTMLElement){t=i;B(t)}e(t,r);E(t);if(y(t,r)===false)return}t.nodeName!=="TEXTAREA"?z(t,r):h.TEXTAREA(t,r)}function z(e,t){var r=w(e,t);var a=t.firstChild;var i=e.firstChild;var l;var o;var u;var s;var c;e:while(a){s=a.nextSibling;l=d(a);while(!r&&i){u=i.nextSibling;if(a.isSameNode&&a.isSameNode(i)){a=s;i=u;continue e}o=d(i);var m=i.nodeType;var N=void 0;if(m===a.nodeType)if(m===p){if(l){if(l!==o)if(c=R[l])if(u===c)N=false;else{e.insertBefore(c,i);o?I(o):P(i,e,true);i=c;o=d(i)}else N=false}else o&&(N=false);N=N!==false&&v(i,a);N&&D(i,a)}else if(m===b||m==A){N=true;i.nodeValue!==a.nodeValue&&(i.nodeValue=a.nodeValue)}if(N){a=s;i=u;continue e}o?I(o):P(i,e,true);i=u}if(l&&(c=R[l])&&v(c,a)){r||U(e,c);D(c,a)}else{var C=f(a);if(C!==false){C&&(a=C);a.actualize&&(a=a.actualize(e.ownerDocument||n));U(e,a);H(a)}}a=s;i=u}M(e,i,o);var T=h[e.nodeName];T&&T(e,t)}var k=t;var F=k.nodeType;var X=r.nodeType;if(!O)if(F===p)if(X===p){if(!v(t,r)){x(t);k=c(t,s(r.nodeName,r.namespaceURI))}}else k=r;else if(F===b||F===A){if(X===F){k.nodeValue!==r.nodeValue&&(k.nodeValue=r.nodeValue);return k}k=r}if(k===r)x(t);else{if(r.isSameNode&&r.isSameNode(k))return;D(k,r,O);if(V)for(var G=0,j=V.length;G<j;G++){var q=R[V[G]];q&&P(q,q.parentNode,false)}}if(!O&&k!==t&&t.parentNode){k.actualize&&(k=k.actualize(t.ownerDocument||n));t.parentNode.replaceChild(k,t)}return k}}var E=g(t);export{E as default};

