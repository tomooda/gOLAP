Class {
	#name : 'GolapQueryPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'networkClient',
		'itemFields',
		'sortKey',
		'sendMax',
		'deadlineTimer',
		'dimensionsKey',
		'dimensionsValues',
		'granularityTransaction',
		'granularityNode',
		'itemFilterSpec',
		'itemFilterPresenter',
		'transactionFilterPresenter',
		'transactionFields',
		'transactionFilterSpec',
		'minSupport',
		'minConfidence',
		'minLift',
		'minJaccard',
		'minPMI',
		'granularityFields',
		'isolatedNodesCheckBox',
		'dimensionsPreview'
	],
	#category : 'Golap-UI-Query',
	#package : 'Golap-UI',
	#tag : 'Query'
}

{ #category : 'instance creation' }
GolapQueryPresenter class >> on: aGolapNetworkClientPresenter [
	^ self new
		networkClient: aGolapNetworkClientPresenter;
		yourself
]

{ #category : 'accessing' }
GolapQueryPresenter >> authenticateBlock [
	^ networkClient ifNotNil: #authenticateBlock
]

{ #category : 'operations' }
GolapQueryPresenter >> clearPreviewFilterField [

	itemFilterPresenter clearPreviewFilterField.
	transactionFilterPresenter clearPreviewFilterField
]

{ #category : 'defaults' }
GolapQueryPresenter >> defaultInitialExtent [
	^ 800@600
]

{ #category : 'layout' }
GolapQueryPresenter >> defaultLayout [

	<script: 'self new open'>
	<spec>
	^ SpPanedLayout newVertical
		  positionOfSlider: 0.6;
		  add: (SpPanedLayout newHorizontal
				   add: (SpBoxLayout newVertical
						    add: 'トランザクション' expand: false;
						    add: transactionFilterPresenter);
				   add: (SpBoxLayout newVertical
						    add: 'アイテム' expand: false;
						    add: itemFilterPresenter);
				   positionOfSlider: 0.5);
		  add: (SpPanedLayout newHorizontal
				   add: (SpBoxLayout newVertical
						    add: (SpGridLayout new
								     beColumnNotHomogeneous;
								     beRowHomogeneous;
								     column: 1 expand: false;
								     column: 2 expand: true;
								     row: 1 expand: false;
								     row: 2 expand: false;
								     row: 3 expand: false;
								     row: 4 expand: false;
								     row: 5 expand: false;
								     row: 6 expand: false;
								     row: 7 expand: false;
								     row: 8 expand: false;
								     borderWidth: 0;
								     add: '最小Support' atPoint: 1 @ 1;
								     add: minSupport atPoint: 2 @ 1;
								     add: '最小Confidence' atPoint: 1 @ 2;
								     add: minConfidence atPoint: 2 @ 2;
								     add: '最小Lift' atPoint: 1 @ 3;
								     add: minLift atPoint: 2 @ 3;
								     add: '最小Jaccard' atPoint: 1 @ 4;
								     add: minJaccard atPoint: 2 @ 4;
								     add: '最小PMI' atPoint: 1 @ 5;
								     add: minPMI atPoint: 2 @ 5;
								     add: 'タイムアウト' atPoint: 1 @ 6;
								     add: deadlineTimer atPoint: 2 @ 6;
								     add: '最大取得件数' atPoint: 1 @ 7;
								     add: sendMax atPoint: 2 @ 7;
								     add: 'ソートキー' atPoint: 1 @ 8;
								     add: sortKey atPoint: 2 @ 8;
								     yourself);
						    add: isolatedNodesCheckBox expand: false;
						    add: '' asPresenter expand: true;
						    yourself);
				   add: (SpBoxLayout newVertical
						    add: (SpGridLayout new
								     beColumnNotHomogeneous;
								     beRowHomogeneous;
								     borderWidth: 0;
								     column: 1 expand: false;
								     column: 2 expand: true;
								     row: 1 expand: false;
								     row: 2 expand: false;
								     row: 3 expand: false;
								     add: '集計' atPoint: 1 @ 1;
								     add: (SpBoxLayout newHorizontal
										      add: granularityTransaction;
										      add: granularityNode)
								     atPoint: 2 @ 1;
								     add: '比較集計変数' atPoint: 1 @ 2;
								     add: dimensionsKey atPoint: 2 @ 2;
								     add: '比較集計値' atPoint: 1 @ 3;
								     add: dimensionsValues atPoint: 2 @ 3;
								     yourself) height: 80;
						    add: dimensionsPreview expand: true));
		  yourself
]

{ #category : 'private' }
GolapQueryPresenter >> flushServerConfig [
	networkClient flushFieldsAndValuesCache.
	transactionFields := nil.
	transactionFilterPresenter updatePreviewList.
	itemFields := nil.
	itemFilterPresenter updatePreviewList.
	granularityFields := nil
]

{ #category : 'accessing-query' }
GolapQueryPresenter >> granularityFields [
	^ granularityFields
		ifNil: [ granularityFields := self serverConfig
				ifNotNil: [ :config | 
					((config at: 'traAttFile' ifAbsentPut: [ Dictionary new ])
						at: 'granuFields'
						ifAbsent: [ String new ]) substrings: ',' ]
				ifNil: [ Array new ] ]
]

{ #category : 'initialization' }
GolapQueryPresenter >> initializePresenters [

	<script: 'GolapQueryPresenter new openWithSpec'>
	transactionFilterPresenter := GolapTransactionFilterPresenter for: self.
	itemFilterPresenter := GolapItemFilterPresenter for: self.
	minSupport := self newNumberInput
		              beFloat;
		              number: 0.0;
		              autoAccept: true;
		              yourself.
	minConfidence := self newNumberInput
		                 beFloat;
		                 number: 0.0;
		                 autoAccept: true;
		                 yourself.
	minLift := self newNumberInput
		           beFloat;
		           number: 0.0;
		           autoAccept: true;
		           yourself.
	minJaccard := self newNumberInput
		              beFloat;
		              number: 0.0;
		              autoAccept: true;
		              yourself.
	minPMI := self newNumberInput
		          beFloat;
		          number: 0.0;
		          autoAccept: true;
		          yourself.
	sortKey := self newTextInput
		           text: 'sup';
		           autoAccept: true;
		           yourself.
	granularityTransaction := self newDropList
		                          display: [ :item | item ifNil: [ '-' ] ];
		                          yourself.
	granularityNode := self newDropList
		                   display: [ :item | item ifNil: [ '-' ] ];
		                   yourself.
	dimensionsKey := self newDropList
		                 display: [ :item | item ifNil: [ '-' ] ];
		                 whenSelectionChangedDo: [ self updateDimensionsPreview ];
		                 yourself.
	dimensionsValues := self newTextInput
		                    text: '';
		                    autoAccept: true;
		                    dropEnabled: true;
		                    acceptDrop: [ :transfer |
			                    dimensionsValues text:
					                    (dimensionsValues text asString trim ifNotEmpty: [ :str | str , ',' ]) , (',' join: transfer passenger) ];
		                    yourself.
	dimensionsPreview := self newList
		                     beMultipleSelection;
		                     dragEnabled: true;
		                     yourself.
	sendMax := self newNumberInput
		           beInteger;
		           number: 1000;
		           yourself.
	deadlineTimer := self newNumberInput
		                 beInteger;
		                 number: 600;
		                 yourself.
	isolatedNodesCheckBox := self newCheckBox
		                         label: '孤立ノードも取得';
		                         state: true;
		                         yourself.
	self whenBuiltDo: [ :w |
			| font |
			font := TextStyle defaultFont.
			w widget allMorphsDo: [ :m | (m respondsTo: #font:) ifTrue: [ m font: font ] ] ]
]

{ #category : 'accessing-query' }
GolapQueryPresenter >> itemFieldQuerySpec [

	^ self serverConfig
		  ifNotNil: [ :config |
				  | querySpec |
				  querySpec := Dictionary new.
				  config at: 'statsFunc' ifPresent: [ :statsFunc | statsFunc keysAndValuesDo: [ :key :value | querySpec at: key put: value ] ].
				  querySpec ]
		  ifNil: [ Dictionary new ]
]

{ #category : 'accessing-query' }
GolapQueryPresenter >> itemFields [
	^ itemFields
		ifNil: [ itemFields := self serverConfig
				ifNotNil: [ :config | 
					(((config at: 'itemAttFile' ifAbsentPut: [ Dictionary new ])
						at: 'strFields'
						ifAbsent: [ String new ]) substrings: ',')
						,
							(((config at: 'itemAttFile' ifAbsentPut: [ Dictionary new ])
								at: 'numFields'
								ifAbsent: [ String new ]) substrings: ',') ]
				ifNil: [ Array new ] ]
]

{ #category : 'accessing-query' }
GolapQueryPresenter >> itemFilterSpec [
	^ itemFilterSpec
		ifNil: [ itemFilterSpec := GolapItemFilterSpec
				withAll:
					(self itemFields
						collect: [ :field | GolapQueryItemClauseSpec on: field ]) ]
]

{ #category : 'accessing-query' }
GolapQueryPresenter >> itemFilterSpec: aGolapItemFilterSpec [
	itemFilterSpec := aGolapItemFilterSpec.
	itemFilterPresenter updateClauseList
]

{ #category : 'accessing' }
GolapQueryPresenter >> minConfidence [

	^ minConfidence number
]

{ #category : 'accessing' }
GolapQueryPresenter >> minConfidence: aNumber [

	minConfidence number: aNumber
]

{ #category : 'accessing' }
GolapQueryPresenter >> minJaccard [

	^ minJaccard number
]

{ #category : 'accessing' }
GolapQueryPresenter >> minJaccard: aNumber [

	minJaccard number: aNumber
]

{ #category : 'accessing' }
GolapQueryPresenter >> minLift [

	^ minLift number
]

{ #category : 'accessing' }
GolapQueryPresenter >> minLift: aNumber [

	minLift number: aNumber
]

{ #category : 'accessing' }
GolapQueryPresenter >> minPMI [

	^ minPMI number
]

{ #category : 'accessing' }
GolapQueryPresenter >> minPMI: aNumber [

	minPMI number: aNumber
]

{ #category : 'accessing' }
GolapQueryPresenter >> minSupport [

	^ minSupport number
]

{ #category : 'accessing' }
GolapQueryPresenter >> minSupport: aNumber [

	minSupport number: aNumber
]

{ #category : 'accessing' }
GolapQueryPresenter >> networkClient [
	^ networkClient
]

{ #category : 'accessing' }
GolapQueryPresenter >> networkClient: aGolapNetworkClientPresenter [
	networkClient := aGolapNetworkClientPresenter
]

{ #category : 'accessing-query' }
GolapQueryPresenter >> query [

	^ GolapJSON toStringPretty: self queryDictionary
]

{ #category : 'accessing-query' }
GolapQueryPresenter >> queryDictionary [

	| q granularity |
	q := OrderedDictionary new.
	self transactionFilterSpec query ifNotEmpty: [ :filter |
		q at: 'traFilter' put: filter ].
	self itemFilterSpec query ifNotEmpty: [ :filter |
		q at: 'itemFilter' put: filter ].
	granularity := OrderedDictionary new.
	granularityTransaction selectedItem ifNotNil: [ :value |
		granularity at: 'transaction' put: value ].
	granularityNode selectedItem ifNotNil: [ :value |
		granularity at: 'node' put: value ].
	granularity ifNotEmpty: [ q at: 'granularity' put: granularity ].
	dimensionsKey selectedItem ifNotNil: [ :key |
		dimensionsValues text asString trim ifNotEmpty: [ :values |
			q at: 'dimension' put: key , ',' , values ] ].
	q at: 'selCond' put: (OrderedDictionary new
			 at: 'minSup' put: self minSupport;
			 at: 'minConf' put: self minConfidence;
			 at: 'minLift' put: self minLift;
			 at: 'minJac' put: self minJaccard;
			 at: 'minPMI' put: self minPMI;
			 yourself).
	sortKey text asString trim ifNotEmpty: [ :value |
		q at: 'sortKey' put: value ].
	[
	sendMax number in: [ :value |
		value > 0 ifTrue: [ q at: 'sendMax' put: value ] ] ]
		on: Error
		do: [ :ex |  ].
	q at: 'isolatedNodes' put: isolatedNodesCheckBox state printString.
	^ OrderedDictionary new
		  at: 'query' put: q;
		  at: 'deadlineTimer' put: (([ deadlineTimer number asInteger ]
				    on: Error
				    do: [ :ex | 0 ]) in: [ :value |
					   value = 0
						   ifTrue: [ 60 ]
						   ifFalse: [ value ] ]);
		  yourself
]

{ #category : 'private' }
GolapQueryPresenter >> resetItemFilterSpec [
	itemFilterSpec := nil.
	itemFilterPresenter updateClauseList
]

{ #category : 'operations' }
GolapQueryPresenter >> resetQuery [
	networkClient flushFieldsAndValuesCache.
	itemFilterPresenter updatePreviewList.
	transactionFilterPresenter updatePreviewList.
	granularityNode selectItem: nil.
	granularityTransaction selectItem: nil.
	dimensionsKey selectItem: nil.
	dimensionsValues text: ''.
	self
		resetItemFilterSpec;
		resetTransactionFilterSpec
]

{ #category : 'private' }
GolapQueryPresenter >> resetTransactionFilterSpec [
	transactionFilterSpec := nil.
	transactionFilterPresenter updateClauseList
]

{ #category : 'accessing' }
GolapQueryPresenter >> serverConfig [
	^ networkClient ifNotNil: #serverConfig
]

{ #category : 'accessing' }
GolapQueryPresenter >> timeout [
	^ 3
]

{ #category : 'accessing-query' }
GolapQueryPresenter >> transactionFields [
	^ transactionFields
		ifNil: [ transactionFields := self serverConfig
				ifNotNil: [ :config | 
					(((config at: 'traAttFile' ifAbsentPut: [ Dictionary new ])
						at: 'strFields'
						ifAbsent: [ String new ]) substrings: ',')
						,
							(((config at: 'traAttFile' ifAbsentPut: [ Dictionary new ])
								at: 'numFields'
								ifAbsent: [ String new ]) substrings: ',') ]
				ifNil: [ Array new ] ]
]

{ #category : 'accessing-query' }
GolapQueryPresenter >> transactionFilterSpec [
	^ transactionFilterSpec
		ifNil: [ transactionFilterSpec := GolapTransactionFilterSpec
				withAll:
					(Array
						streamContents: [ :stream | 
							self transactionFields
								do:
									[ :field | stream nextPut: (GolapQueryTransactionClauseSpec on: field) ].
							self itemFields
								do: [ :field | stream nextPut: (GolapQueryItemClauseSpec on: field) ] ]) ]
]

{ #category : 'accessing-query' }
GolapQueryPresenter >> transactionFilterSpec: aGolapTransactionFilterSpec [
	transactionFilterSpec := aGolapTransactionFilterSpec.
	transactionFilterPresenter updateClauseList
]

{ #category : 'private' }
GolapQueryPresenter >> updateDimensionsPreview [
	dimensionsKey selectedItem
		ifNotNil: [ :key | 
			dimensionsPreview
				items:
					(transactionFilterPresenter
						availableItemsFor: (GolapQueryTransactionClauseSpec on: key)) ]
]

{ #category : 'private-query' }
GolapQueryPresenter >> updateQuery [
	networkClient ifNil: [ ^ self ].
	networkClient serverConfig
		ifNotNil: [ :config | 
			config
				at: 'etc'
					ifPresent: [ :etc | 
					etc
						at: 'deadlineTimer'
							ifPresent: [ :value | 
							deadlineTimer
								text: value asString;
								selectAll ];
						at: 'sendMax'
							ifPresent: [ :value | 
							sendMax
								text: value asString;
								selectAll ] ];
				at: 'selCond'
					ifPresent: [ :conds | 
					conds
						at: 'minJac' ifPresent: [ :value | self minJaccard: value ];
						at: 'minPMI' ifPresent: [ :value | self minPMI: value ];
						at: 'minConf' ifPresent: [ :value | self minConfidence: value ];
						at: 'minSup' ifPresent: [ :value | self minSupport: value ];
						at: 'minLift' ifPresent: [ :value | self minLift: value ] ] ]
]

{ #category : 'private' }
GolapQueryPresenter >> updateServerConfig [
	self updateQuery.
	networkClient flushFieldsAndValuesCache.
	itemFilterPresenter updatePreviewList.
	transactionFilterPresenter updatePreviewList.
	(self itemFields copyWithFirst: nil)
		in: [ :items | 
			granularityNode listItems = items
				ifFalse: [ granularityNode items: (self itemFields copyWithFirst: nil) ] ].
	(self granularityFields copyWithFirst: nil)
		in: [ :items | 
			granularityTransaction listItems = items
				ifFalse: [ granularityTransaction items: items ] ].
	(self transactionFields copyWithFirst: nil)
		in: [ :items | 
			dimensionsKey listItems = items
				ifFalse: [ dimensionsKey items: items ] ]
]

{ #category : 'accessing' }
GolapQueryPresenter >> url [
	^ networkClient ifNotNil: #url
]
