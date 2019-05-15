// This file contains the source for the Javascript side of the
// WebViewJavascriptBridge. It is plaintext, but converted to an NSString
// via some preprocessor tricks.
//
// Previous implementations of WebViewJavascriptBridge loaded the javascript source
// from a resource. This worked fine for app developers, but library developers who
// included the bridge into their library, awkwardly had to ask consumers of their
// library to include the resource, violating their encapsulation. By including the
// Javascript as a string resource, the encapsulation of the library is maintained.

#import "GrayN_WebViewJavascriptBridge_JS.h"

NSString * WebViewJavascriptBridge_js() {
#define __wvjb_js_func__(x) #x
    
    // BEGIN preprocessorJSCode
    static NSString * preprocessorJSCode = @__wvjb_js_func__(
                                                             
                                                             ;
                                                             if(window.Base64) {
                                                                 console.log("load base64 util from web");
                                                             } else {
                                                                 console.log("load base64 util from local");
                                                                 (function(global){"use strict";var _Base64=global.Base64;var version="2.1.9";var buffer;if(typeof module!=="undefined"&&module.exports){try{buffer=require("buffer").Buffer}catch(err){}}var b64chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";var b64tab=function(bin){var t={};for(var i=0,l=bin.length;i<l;i++)t[bin.charAt(i)]=i;return t}(b64chars);var fromCharCode=String.fromCharCode;var cb_utob=function(c){if(c.length<2){var cc=c.charCodeAt(0);return cc<128?c:cc<2048?fromCharCode(192|cc>>>6)+fromCharCode(128|cc&63):fromCharCode(224|cc>>>12&15)+fromCharCode(128|cc>>>6&63)+fromCharCode(128|cc&63)}else{var cc=65536+(c.charCodeAt(0)-55296)*1024+(c.charCodeAt(1)-56320);return fromCharCode(240|cc>>>18&7)+fromCharCode(128|cc>>>12&63)+fromCharCode(128|cc>>>6&63)+fromCharCode(128|cc&63)}};var re_utob = new RegExp('[\uD800-\uDBFF][\uDC00-\uDFFFF]|[^\x00-\x7F]', 'g');var utob=function(u){return u.replace(re_utob,cb_utob)};var cb_encode=function(ccc){var padlen=[0,2,1][ccc.length%3],ord=ccc.charCodeAt(0)<<16|(ccc.length>1?ccc.charCodeAt(1):0)<<8|(ccc.length>2?ccc.charCodeAt(2):0),chars=[b64chars.charAt(ord>>>18),b64chars.charAt(ord>>>12&63),padlen>=2?"=":b64chars.charAt(ord>>>6&63),padlen>=1?"=":b64chars.charAt(ord&63)];return chars.join("")};var btoa=global.btoa?function(b){return global.btoa(b)}:function(b){return b.replace(/[\s\S]{1,3}/g,cb_encode)};var _encode=buffer?function(u){return(u.constructor===buffer.constructor?u:new buffer(u)).toString("base64")}:function(u){return btoa(utob(u))};var encode=function(u,urisafe){return!urisafe?_encode(String(u)):_encode(String(u)).replace(/[+\/]/g,function(m0){return m0=="+"?"-":"_"}).replace(/=/g,"")};var encodeURI=function(u){return encode(u,true)};var re_btou=new RegExp(["[À-ß][-¿]","[à-ï][-¿]{2}","[ð-÷][-¿]{3}"].join("|"),"g");var cb_btou=function(cccc){switch(cccc.length){case 4:var cp=(7&cccc.charCodeAt(0))<<18|(63&cccc.charCodeAt(1))<<12|(63&cccc.charCodeAt(2))<<6|63&cccc.charCodeAt(3),offset=cp-65536;return fromCharCode((offset>>>10)+55296)+fromCharCode((offset&1023)+56320);case 3:return fromCharCode((15&cccc.charCodeAt(0))<<12|(63&cccc.charCodeAt(1))<<6|63&cccc.charCodeAt(2));default:return fromCharCode((31&cccc.charCodeAt(0))<<6|63&cccc.charCodeAt(1))}};var btou=function(b){return b.replace(re_btou,cb_btou)};var cb_decode=function(cccc){var len=cccc.length,padlen=len%4,n=(len>0?b64tab[cccc.charAt(0)]<<18:0)|(len>1?b64tab[cccc.charAt(1)]<<12:0)|(len>2?b64tab[cccc.charAt(2)]<<6:0)|(len>3?b64tab[cccc.charAt(3)]:0),chars=[fromCharCode(n>>>16),fromCharCode(n>>>8&255),fromCharCode(n&255)];chars.length-=[0,0,2,1][padlen];return chars.join("")};var atob=global.atob?function(a){return global.atob(a)}:function(a){return a.replace(/[\s\S]{1,4}/g,cb_decode)};var _decode=buffer?function(a){return(a.constructor===buffer.constructor?a:new buffer(a,"base64")).toString()}:function(a){return btou(atob(a))};var decode=function(a){return _decode(String(a).replace(/[-_]/g,function(m0){return m0=="-"?"+":"/"}).replace(/[^A-Za-z0-9\+\/]/g,""))};var noConflict=function(){var Base64=global.Base64;global.Base64=_Base64;return Base64};global.Base64={VERSION:version,atob:atob,btoa:btoa,fromBase64:decode,toBase64:encode,utob:utob,encode:encode,encodeURI:encodeURI,btou:btou,decode:decode,noConflict:noConflict};if(typeof Object.defineProperty==="function"){var noEnum=function(v){return{value:v,enumerable:false,writable:true,configurable:true}};global.Base64.extendString=function(){Object.defineProperty(String.prototype,"fromBase64",noEnum(function(){return decode(this)}));Object.defineProperty(String.prototype,"toBase64",noEnum(function(urisafe){return encode(this,urisafe)}));Object.defineProperty(String.prototype,"toBase64URI",noEnum(function(){return encode(this,true)}))}}if(global["Meteor"]){Base64=global.Base64}})(this);
                                                             }
                                                             console.log("load base64 util finished");
                                                             ;
                                                             (function() {
        
        
        if (window.WebViewJavascriptBridge) {
            return;
        }
        window.WebViewJavascriptBridge = {
        registerHandler: registerHandler,
        callHandler: callHandler,
        _fetchQueue: _fetchQueue,
        _handleMessageFromObjC: _handleMessageFromObjC,
        init:init
        };
        
        var bridgeVersion = "1.0";
        var messagingIframe;
        var sendMessageQueue = [];
        var messageHandlers = {};
        
        var CUSTOM_PROTOCOL_SCHEME = 'opsdkdl';
        var QUEUE_HAS_MESSAGE = '__WVJB_QUEUE_MESSAGE__';
        
        var responseCallbacks = {};
        var uniqueId = 1;
        
        function registerHandler(handlerName, handler) {
            messageHandlers[handlerName] = handler;
        }
        
        function init(handler) {
            console.log("ios webviewjavascriptbrige init");
        }
        
        function callHandler(handlerName, data, responseCallback) {
            if (arguments.length == 2 && typeof data == 'function') {
                responseCallback = data;
                data = null;
            }
            _doSend({ handlerName:handlerName, data:data }, responseCallback);
        }
        
        
        
        function _doSend(message, responseCallback) {
            if (responseCallback) {
                var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
                responseCallbacks[callbackId] = responseCallback;
                message['callbackId'] = callbackId;
            }
            sendMessageQueue.push(message);
            messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
        }
        
        function _fetchQueue() {
            var messageQueueString = JSON.stringify(sendMessageQueue);
            if(messageQueueString) {
                messageQueueString = _encodeBase64(messageQueueString);
            }
            sendMessageQueue = [];
            return messageQueueString;
        }
        
        function _dispatchMessageFromObjC(messageJSON) {
            console.log("_dispatchMessageFromNative:");
            setTimeout(function _timeoutDispatchMessageFromObjC() {
                if(messageJSON) {
                    messageJSON = _decodeBase64(messageJSON);
                }
                var message = JSON.parse(messageJSON);
                var messageHandler;
                var responseCallback;
                
                if (message.responseId) {
                    responseCallback = responseCallbacks[message.responseId];
                    if (!responseCallback) {
                        return;
                    }
                    responseCallback(message.responseData);
                    delete responseCallbacks[message.responseId];
                } else {
                    if (message.callbackId) {
                        var callbackResponseId = message.callbackId;
                        responseCallback = function(responseData) {
                            _doSend({ responseId:callbackResponseId, responseData:responseData });
                        };
                    }
                    
                    var handler = messageHandlers[message.handlerName];
                    try {
                        handler(message.data, responseCallback);
                    } catch(exception) {
                        console.log("WebViewJavascriptBridge: WARNING: javascript handler threw.", message, exception);
                    }
                    if (!handler) {
                        console.log("WebViewJavascriptBridge: WARNING: no handler for message from ObjC:", message);
                    }
                }
            });
        }
        
        function _handleMessageFromObjC(messageJSON) {
            _dispatchMessageFromObjC(messageJSON);
        }
        
        function _decodeBase64(data) {
            if(data && data != "") {
                window&&window._debug&&console.log("decodeBase64 before:" + data);
                var _result = Base64.decode(data);
                window&&window._debug&&console.log("decodeBase64 finished:" + _result);
                return _result;
            }
            return data;
        }
        
        function _encodeBase64(data) {
            if(data && data != "") {
                window&&window._debug&&console.log("encodeBase64 before:" + data);
                var _result =  Base64.encode(data);
                window&&window._debug&&console.log("encodeBase64 finished:" + _result);
                return _result;
            }
            return data;
        }
        
        messagingIframe = document.createElement('iframe');
        messagingIframe.style.display = 'none';
        messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
        document.documentElement.appendChild(messagingIframe);
        
        /*初始化jsBridge后告诉页面*/
        var doc = document;
        var readyEvent = doc.createEvent('Events');
        readyEvent.initEvent('WebViewJavascriptBridgeReady');
        readyEvent.bridge = WebViewJavascriptBridge;
        doc.dispatchEvent(readyEvent);
        console.log("WebViewJavascriptBridge init success!--"+bridgeVersion);
        
    })();
                                                             
                                                             
                                                             ); // END preprocessorJSCode
    
#undef __wvjb_js_func__
    return preprocessorJSCode;
};
