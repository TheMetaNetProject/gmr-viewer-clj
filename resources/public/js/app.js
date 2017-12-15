'use strict';

/**
 * app.js
 */

var gmrViewerApp = angular.module('gmrViewerApp', ['ngRoute', 'documentControllers',
         'documentServices', 'd3', 'dagreD3', 'documentDirectives', 'cgBusy']);

gmrViewerApp.constant('_', window._);

gmrViewerApp.filter('unsafe', function($sce) {
   return function(val) {
      return $sce.trustAsHtml(val);
   };
});

gmrViewerApp.filter('remove', function() {
   return function(input, drop, sep2, repl) {
      var elements;
      if (input.length > 0 && drop) {
         drop = new RegExp(drop, 'i');
         elements = _.map(input, function(x) {
            return x.split(drop)[1];
         });
      }

      if (elements && sep2 && repl) {
         sep2 = new RegExp(sep2, 'g');
         return _.map(elements, function(s) {
            return s.replace(sep2, repl);
         });
      }
      else 
         return ['(none)'];
   };
});

gmrViewerApp.filter('join', function() {
   return function(input, joiner) {
      joiner = (typeof joiner === 'undefined') ? ', ' : joiner;
      return (input && input.length > 0) ? input.join(joiner) : '(none)';
   };
});

gmrViewerApp.filter('splitElements', function() {
   return function(input, sep) {
      sep = sep ? new RegExp(sep, 'i') : ',';
      if (! input) 
          return [[]];
      else
          return _.map(input, function(s) { return s.split(sep); });
   };
});

gmrViewerApp.filter('split', function() {
   return function(input, sep) {
      sep = sep ? new RegExp(sep, 'i') : ',';
      return input ? input.split(sep) : [];
   };
});

gmrViewerApp.filter('take', function() {
   return _.take;
});

gmrViewerApp.filter('drop', function() {
   return _.drop;
});

gmrViewerApp.filter('flatten', function() {
   return _.flatten;
});

gmrViewerApp.config(['$routeProvider', function($routeProvider) {
   $routeProvider.when('/docs/:coll/', {
      templateUrl: 'public/partials/docs.html', controller: 'DocumentListCtrl'
   });

   $routeProvider.when('/docs/:coll/doc/:docId', {
      templateUrl: 'public/partials/item.html', controller: 'DocumentItemCtrl'
   });

   $routeProvider.otherwise({
      redirectTo: '/docs/en'
   });
}]);

