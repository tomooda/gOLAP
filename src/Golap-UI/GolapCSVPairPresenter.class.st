Class {
	#name : 'GolapCSVPairPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'basepathField',
		'changeBasepathButton',
		'nodeCSVList',
		'edgeCSVList',
		'nameField'
	],
	#classInstVars : [
		'lastBasepath'
	],
	#category : 'Golap-UI-CSV',
	#package : 'Golap-UI',
	#tag : 'CSV'
}

{ #category : 'accessing' }
GolapCSVPairPresenter class >> defaultBasepath [

	^ (FileLocator documents / 'gOLAP') asFileReference
]

{ #category : 'layout' }
GolapCSVPairPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: 'ベースフォルダ' expand: false;
				   add: #basepathField expand: true;
				   add: #changeBasepathButton expand: false)
		  expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: (SpBoxLayout newVertical
						    add: 'アイテムCSV' expand: false;
						    add: #nodeCSVList expand: true)
				   expand: true;
				   add: (SpBoxLayout newVertical
						    add: '関連性CSV' expand: false;
						    add: #edgeCSVList expand: true)
				   expand: true)
		  expand: true;
		  add: (SpBoxLayout newHorizontal
				   add: 'ディメンジョン名' expand: false;
				   add: #nameField expand: true)
		  expand: false
]

{ #category : 'accessing' }
GolapCSVPairPresenter class >> flushLastBasepath [

	lastBasepath := nil
]

{ #category : 'accessing' }
GolapCSVPairPresenter class >> lastBasepath [

	(lastBasepath isNil or: [ lastBasepath isDirectory not ]) ifTrue: [
		lastBasepath := self defaultBasepath ].
	^ lastBasepath
]

{ #category : 'accessing' }
GolapCSVPairPresenter class >> lastBasepath: anObject [

	lastBasepath := anObject
]

{ #category : 'updating' }
GolapCSVPairPresenter >> basepathChanged [

	self class lastBasepath: self basepathReference.
	self
		updateNodeCSVList;
		updateEdgeCSVList
]

{ #category : 'accessing' }
GolapCSVPairPresenter >> basepathReference [

	^ basepathField text trim ifNotEmpty: #asFileReference
]

{ #category : 'operations' }
GolapCSVPairPresenter >> changeBasepath [

	StOpenDirectoryPresenter new
		defaultFolder: (self basepathReference
				 ifNotNil: [ :ref |
					 ref isFile
						 ifTrue: [ ref parent ]
						 ifFalse: [ ref ] ]
				 ifNil: [ FileLocator documents / 'gOLAP' ]);
		okAction: [ :ref |
			basepathField text: ref absolutePath pathString.
			self basepathChanged ];
		open
]

{ #category : 'accessing' }
GolapCSVPairPresenter >> edgeCSVFileReference [

	^ edgeCSVList selectedItem ifNotNil: [ :basename |
		  | ref |
		  ref := self basepathReference / basename.
		  ref isFile ifTrue: [ ref ] ]
]

{ #category : 'initialization' }
GolapCSVPairPresenter >> initializePresenters [

	super initializePresenters.
	basepathField := self newTextInput
		                 text:
			                 self class lastBasepath absolutePath pathString;
		                 whenChangedDo: [ self basepathChanged ];
		                 whenSubmitDo: [ :t | self basepathChanged ];
		                 yourself.
	changeBasepathButton := self newButton
		                        icon: (self iconNamed: #open);
		                        action: [ self changeBasepath ];
		                        yourself.
	nodeCSVList := self newList
		               whenSelectedItemChangedDo: [
			               self selectedNodeCSVChanged ];
		               yourself.
	edgeCSVList := self newList
		               whenSelectedItemChangedDo: [
			               self selectedEdgeCSVChanged ];
		               yourself.
	nameField := self newTextInput.
	self whenBuiltDo: [
		nameField text: ''.
		self basepathChanged ]
]

{ #category : 'initialization' }
GolapCSVPairPresenter >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.
	aSpWindowPresenter
		title: 'CSV選択';
		initialExtent: 600 @ 400
]

{ #category : 'accessing' }
GolapCSVPairPresenter >> nodeCSVFileReference [

	^ nodeCSVList selectedItem ifNotNil: [ :basename |
		  | ref |
		  ref := self basepathReference / basename.
		  ref isFile ifTrue: [ ref ] ]
]

{ #category : 'accessing' }
GolapCSVPairPresenter >> pairName [

	^ nameField text trim ifEmpty: [ self basepathReference basename ]
]

{ #category : 'updating' }
GolapCSVPairPresenter >> selectedEdgeCSVChanged [

	self updateNameField
]

{ #category : 'updating' }
GolapCSVPairPresenter >> selectedNodeCSVChanged [

	self updateNameField
]

{ #category : 'updating' }
GolapCSVPairPresenter >> updateEdgeCSVList [

	self basepathReference isDirectory ifTrue: [
		edgeCSVList items:
			(self basepathReference fileNames sorted select: [ :basename |
				 basename endsWith: '-r.csv' ]) ]
]

{ #category : 'updating' }
GolapCSVPairPresenter >> updateNameField [

	nameField text asString trim ifEmpty: [
		| name1 name2 |
		name1 := (nodeCSVList selectedItem ifNil: [ ^ self ])
			         withoutSuffix: '-i.csv'.
		name2 := (edgeCSVList selectedItem ifNil: [ ^ self ])
			         withoutSuffix: '-r.csv'.
		(name1 isEmpty or: [ name2 isEmpty ]) ifTrue: [ ^ self ].
		name1 first = name2 first ifTrue: [
			| index |
			index := (1 to: (name1 size min: name2 size))
				         detect: [ :i | (name1 at: i) ~= (name2 at: i) ]
				         ifNone: [ (name1 size min: name2 size) + 1 ].
			nameField text: (name1 copyFrom: 1 to: index - 1).
			^ self ].
		name1 := name1 reversed.
		name2 := name2 reversed.
		name1 first = name2 first ifTrue: [
			| index |
			index := (1 to: (name1 size min: name2 size))
				         detect: [ :i | (name1 at: i) ~= (name2 at: i) ]
				         ifNone: [ (name1 size min: name2 size) + 1 ].
			nameField text: (name1 copyFrom: 1 to: index - 1) reversed.
			^ self ].
		nameField text: name1 ]
]

{ #category : 'updating' }
GolapCSVPairPresenter >> updateNodeCSVList [

	self basepathReference isDirectory ifTrue: [
		nodeCSVList items:
			(self basepathReference fileNames sorted select: [ :basename |
				 basename endsWith: '-i.csv' ]) ]
]
