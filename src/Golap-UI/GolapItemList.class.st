Class {
	#name : #GolapItemList,
	#superclass : #SpPresenter,
	#instVars : [
		'golap',
		'markerDropList',
		'lastSelectedMarkerIndex',
		'queryField',
		'markers',
		'presetQueryButton',
		'vertexList'
	],
	#classVars : [
		'EmptyImage',
		'ImageRepositoryUrl'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #layout }
GolapItemList class >> defaultLayout [

	<spec>
	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: #markerDropList width: 50;
				   add: #queryField;
				   add: #presetQueryButton width: 20)
		  height: self buttonHeight;
		  add: #vertexList
]

{ #category : #adding }
GolapItemList >> add: aGolapVertex toMarker: aColor [

	self updateGlobalImageAfter: [ 
		aGolapVertex dataDo: [ :data | 
			(markers at: aColor ifAbsentPut: [ Set new ]) add: data ].
		markerDropList items do: [ :assoc | 
			assoc key = aColor ifTrue: [ 
				| patterns regexs |
				patterns := (assoc value substrings: ',')
					            collect: #trim
					            thenSelect: #notEmpty.
				regexs := patterns collect: [ :pattern | self regexFor: pattern ].
				(regexs anySatisfy: [ :regex | regex matches: aGolapVertex name ]) 
					ifFalse: [ patterns := patterns copyWith: aGolapVertex name ].
				assoc value: (',' join: patterns) ] ].
		self currentMarker: aColor.
		self updateVertexList ]
]

{ #category : #'accessing-markers' }
GolapItemList >> addAll: aCollectionOfGolapVertex toMarker: aColor [

	self updateGlobalImageAfter: [ 
		aCollectionOfGolapVertex do: [ :vertex | 
			vertex dataDo: [ :data | 
				(markers at: aColor ifAbsentPut: [ Set new ]) add: data ] ].
		markerDropList items do: [ :assoc | 
			assoc key = aColor ifTrue: [ 
				| patterns regexs |
				patterns := (assoc value substrings: ',')
					            collect: #trim
					            thenSelect: #notEmpty.
				regexs := patterns collect: [ :pattern | self regexFor: pattern ].
				aCollectionOfGolapVertex do: [ :vertex | 
					(regexs anySatisfy: [ :regex | regex matches: vertex name ]) 
						ifFalse: [ patterns := patterns copyWith: vertex name ] ].
				assoc value: (',' join: patterns) ] ].
		self currentMarker: aColor.
		self updateVertexList ]
]

{ #category : #'accessing-markers' }
GolapItemList >> addMarkerColor [

	self withAdapterDo: [ :a | 
		a widget ifNotNil: [ :widget | 
			(widget theme
				 chooseColorIn:
				 ((widget ownerThatIsA: SystemWindow) ifNil: [ widget ])
				 title: 'Choose Color' translated
				 color: Color black)
				ifNotNil: [ :c | self addMarkerColor: c ]
				ifNil: [ 
					((markerDropList selection class slotNamed: #selectedIndex) 
						 rawRead: markerDropList selection)
						rawValue: (lastSelectedMarkerIndex ifNil: [ 0 ]);
						valueChanged: (lastSelectedMarkerIndex ifNil: [ 0 ]) ] ] ]
]

{ #category : #'accessing-markers' }
GolapItemList >> addMarkerColor: aColor [

	| items |
	markerDropList listItems do: [ :assoc | 
		assoc key = aColor ifTrue: [ 
			markerDropList selectItem: assoc.
			^ self ] ].
	markers at: aColor put: Set new.
	items := markerDropList listItems.
	markerDropList
		items: (items copyFrom: 1 to: items size - 1) , { 
					(aColor -> '').
					items last };
		selectItem: aColor -> ''
]

{ #category : #adding }
GolapItemList >> addSelectionsToMarker: aColor [

	self golapDo: [ :g | self addAll: g selections toMarker: aColor ]
]

{ #category : #'accessing-markers' }
GolapItemList >> currentMarker [
	^ markerDropList selectedItem ifNotNil: #key
]

{ #category : #'accessing-markers' }
GolapItemList >> currentMarker: aColor [
	| item |
	item := markerDropList getList
		detect: [ :assoc | 
			assoc model
				ifNil: [ aColor isNil ]
				ifNotNil: [ assoc model key = aColor ] ]
		ifNone: [ ^ nil ].
	markerDropList selectItem: item model
]

{ #category : #accessing }
GolapItemList >> golap: aGolap [
	golap := aGolap
]

{ #category : #accessing }
GolapItemList >> golapDo: aBlock [

	^ golap ifNotNil: aBlock
]

{ #category : #private }
GolapItemList >> iconForCircleColor: aColor [

	| icon canvas |
	icon := Form extent: 16 @ 16 depth: 32.
	canvas := icon getCanvas.
	canvas fillColor: Color transparent.
	aColor ifNotNil: [ 
		canvas frameOval: (1 @ 1 corner: 14 @ 14) width: 2 color: aColor ].
	^ icon
]

{ #category : #private }
GolapItemList >> iconForSelector: aSymbol [
	aSymbol = #addMarkerColor
		ifTrue: [ ^ Smalltalk ui icons
				iconNamed: #add
				ifNone: [ | form canvas |
					form := Form extent: 16 @ 16 depth: 32.
					canvas := form getCanvas.
					canvas
						fillColor: Color transparent;
						line: 0 @ 8
							to: 16 @ 8
							width: 3
							color: Color green darker;
						line: 8 @ 0
							to: 8 @ 16
							width: 3
							color: Color green darker.
					form ] ]
]

{ #category : #initialization }
GolapItemList >> initialize [

	super initialize.
	markers := OrderedDictionary new
]

{ #category : #initialization }
GolapItemList >> initializePresenters [

	markerDropList := self newDropList
		                  items: { 
				                  (nil -> '').
				                  (Color red -> '').
				                  (Color yellow darker -> '').
				                  (Color green -> '').
				                  (Color blue -> '').
				                  (#addMarkerColor -> '') };
		                  display: [ :assoc | '' ];
		                  displayIcon: [ :assoc | 
			                  assoc key
				                  ifNotNil: [ :c | 
					                  c isSymbol
						                  ifTrue: [ self iconForSelector: c ]
						                  ifFalse: [ self iconForCircleColor: c ] ]
				                  ifNil: [ nil ] ];
		                  whenSelectedItemChangedDo: [ 
			                  markerDropList selectedItem ifNotNil: [ 
					                  :selectedItem | 
					                  selectedItem key isSymbol
						                  ifTrue: [ self perform: selectedItem key ]
						                  ifFalse: [ 
							                  lastSelectedMarkerIndex := markerDropList
								                                             selectedIndex.
							                  queryField text: selectedItem value asText.
							                  self updateVertexList.
							                  self updateGlobalImage ] ] ];
		                  yourself.
	lastSelectedMarkerIndex := 0.
	queryField := self newTextInput whenSubmitDo: [ :txt | 
		              | text |
		              text := queryField text asString trim.
		              self updateGlobalImageAfter: [ 
			              | selectedMarker |
			              selectedMarker := markerDropList selectedItem.
			              selectedMarker value: text.
			              text
				              ifEmpty: [ 
				              markers removeKey: selectedMarker key ifAbsent: [  ] ]
				              ifNotEmpty: [ :q | 
					              | regexs |
					              regexs := (q substrings: ',') collect: [ :pattern | 
						                        self regexFor: pattern trim ].
					              markers at: selectedMarker key put: (self vertices
							               select: [ :v | 
							               regexs anySatisfy: [ :regex | 
								               regex matches: v name ] ]
							               thenCollect: #data) asSet ].
			              self updateVertexList ] ].
	presetQueryButton := self newButton
		                     icon: (Smalltalk ui icons iconNamed: #back);
		                     action: [ golap openPresetQueryDialog ];
		                     yourself.
	vertexList := self newTable
		              beSingleSelection;
		              disableSearch;
		              addColumn: (SpStringTableColumn new
				               width: 80;
				               evaluated: [ :id | 
					               self simpleStringFor:
							               (self model valueAtVertex:
									                (self model vertexAt: id)) ]);
		              addColumn:
			              (SpStringTableColumn new evaluated: [ :id | 
				               (self model vertexAt: id) name ]);
		              contextMenu: [ self vertexListMenu ];
		              whenSelectionChangedDo: [ 
			              self updateGlobalImageAfter: [ 
				              vertexList selection selectedItem
					              ifNil: [ golap unselectAll ]
					              ifNotNil: [ :data | 
					              golap select: (self model vertexAt: data) ].
				              golap updateItemView ] ];
		              yourself
]

{ #category : #menu }
GolapItemList >> markMenu: aGolapVertex [

	| markMenu |
	markMenu := self newMenu.
	markerDropList listItems do: [ :listItem | 
		| color |
		color := listItem key.
		color isSymbol ifFalse: [ 
			((markers at: color ifAbsent: [ #(  ) ]) includes:
				 aGolapVertex data) ifFalse: [ 
				markMenu addItem: [ :menuItem | 
					menuItem
						name: '';
						icon: (self iconForCircleColor: color);
						action: [ self add: aGolapVertex toMarker: color ] ] ] ] ].
	^ markMenu
]

{ #category : #menu }
GolapItemList >> markSelectionsMenu [

	| markMenu |
	markMenu := self newMenu.
	markerDropList listItems do: [ :listItem | 
		| color |
		color := listItem key.
		color isSymbol ifFalse: [ 
			markMenu addItem: [ :menuItem | 
				menuItem
					name: '';
					icon: (self iconForCircleColor: color);
					action: [ self addSelectionsToMarker: color ] ] ] ].
	^ markMenu
]

{ #category : #'accessing-markers' }
GolapItemList >> markedVertices [

	| ids |
	ids := markers
		       at: (markerDropList selectedItem ifNotNil: #key)
		       ifAbsent: [ Array new ].
	^ self model vertices asArray select: [ :v | 
		  ids anySatisfy: [ :id | v hasData: id ] ]
]

{ #category : #private }
GolapItemList >> markerDropList [
	^ markerDropList
]

{ #category : #private }
GolapItemList >> markers [
	^ markers
]

{ #category : #enumerating }
GolapItemList >> markersAndVerticesDo: aBlock [

	self modelDo: [ :model | 
		markers keysAndValuesDo: [ :key :ids | 
			aBlock value: key value: (model vertices asArray select: [ :v | 
					 ids anySatisfy: [ :id | v hasData: id ] ]) ] ]
]

{ #category : #accessing }
GolapItemList >> model [

	^ golap ifNotNil: #model
]

{ #category : #accessing }
GolapItemList >> modelDo: aBlock [

	^ self golapDo: [ :g | g model ifNotNil: aBlock ]
]

{ #category : #private }
GolapItemList >> queryField [

	^ queryField
]

{ #category : #private }
GolapItemList >> regexFor: aString [
	| regex |
	regex := #('\' '.' '[' ']' '(' ')' '!' '+')
		inject: aString
		into: [ :p :special | p copyReplaceAll: special with: '\' , special ].
	^ ((regex copyReplaceAll: '*' with: '.*')
		copyReplaceAll: '?'
		with: '[ -~]+') asRegex
]

{ #category : #removing }
GolapItemList >> remove: aGolapVertex fromMarker: aColor [

	self updateGlobalImageAfter: [ 
		markers
			at: aColor
			ifPresent: [ :set | 
			aGolapVertex dataDo: [ :data | set remove: data ] ]
			ifAbsent: [ ^ self ].
		markerDropList items do: [ :assoc | 
			assoc key = aColor ifTrue: [ 
				| patterns |
				patterns := (assoc value substrings: ',')
					            collect: #trim
					            thenSelect: #notEmpty.
				patterns := patterns copyWithout:  aGolapVertex name.
				assoc value: (',' join: patterns) ] ].
		self currentMarker: aColor.
		self updateVertexList ]
]

{ #category : #removing }
GolapItemList >> removeAll: aCollectionOfGolapVertex fromMarker: aColor [

	self updateGlobalImageAfter: [ 
		markers
			at: aColor
			ifPresent: [ :set | 
				aCollectionOfGolapVertex do: [ :v | 
					v dataDo: [ :data | set remove: data ifAbsent: [  ] ] ] ]
			ifAbsent: [ ^ self ].
		(markers at: aColor) ifEmpty: [ markers removeKey: aColor ].
		markerDropList items do: [ :assoc | 
			assoc key = aColor ifTrue: [ 
				| patterns |
				patterns := (assoc value substrings: ',')
					            collect: #trim
					            thenSelect: #notEmpty.
				patterns := patterns reject: [ :pattern | aCollectionOfGolapVertex anySatisfy: [ :vertex | vertex name = pattern ]].
				assoc value: (',' join: patterns) ] ].
		self currentMarker: aColor.
		self updateVertexList ]
]

{ #category : #removing }
GolapItemList >> removeSelectionsFromMarker: aColor [
	self removeAll: golap selections fromMarker: aColor
]

{ #category : #snapshot }
GolapItemList >> restore: aStream [

	((NeoJSONReader on: aStream)
		 mapClass: OrderedDictionary;
		 next) ifNotNil: [ :json | 
		| colorMap |
		colorMap := Dictionary new.
		json
			at: 'selectedMarkerIndex'
			ifPresent: [ :int | lastSelectedMarkerIndex := int ];
			at: 'markerFilters' ifPresent: [ :dict | 
				markerDropList items: (dict keys collect: [ :colorString | 
								 (colorString ifEmpty: [ nil ] ifNotEmpty: [ 
										  colorMap
											  at: colorString
											  ifAbsentPut: [ Color fromHexString: colorString ] ])
								 -> (dict at: colorString) ]).
				lastSelectedMarkerIndex ifNotNil: [ 
						markerDropList selectIndex: lastSelectedMarkerIndex ] ];
			at: 'markerVertices' ifPresent: [ :dict | 
				markers := (dict keys collect: [ :colorString | 
						            (colorString ifEmpty: [ nil ] ifNotEmpty: [ 
								             colorMap
									             at: colorString
									             ifAbsentPut: [ Color fromHexString: colorString ] ])
						            -> (dict at: colorString) asSet ]) asDictionary ].
		self updateVertexList ]
]

{ #category : #accessing }
GolapItemList >> selectedItem [

	^ vertexList selection selectedItem
]

{ #category : #private }
GolapItemList >> simpleStringFor: aNumber [

	^ golap simpleStringFor: aNumber
]

{ #category : #snapshot }
GolapItemList >> snapshot [

	golap snapshotItemList: [ :stream | self snapshotInto: stream ]
]

{ #category : #snapshot }
GolapItemList >> snapshotColor: aColor [

	^ aColor ifNil: [ '' ] ifNotNil: [ 
		  aColor isColor
			  ifTrue: [ aColor asHexString ]
			  ifFalse: [ aColor ] ]
]

{ #category : #snapshot }
GolapItemList >> snapshotInto: aStream [

	| json |
	json := OrderedDictionary new.
	json at: 'selectedMarkerIndex' put: lastSelectedMarkerIndex.
	json
		at: 'markerFilters'
		put: (markerDropList items collect: [ :colorAndPatternString | 
				 (self snapshotColor: colorAndPatternString key)
				 -> colorAndPatternString value ]) asOrderedDictionary.
	json at: 'markerVertices' put: (markers keys collect: [ :color | 
			 (self snapshotColor: color) -> (markers at: color) ])
			asOrderedDictionary.
	(NeoJSONWriter on: aStream) nextPut: json
]

{ #category : #menu }
GolapItemList >> unmarkMenu: aGolapVertex [
	| unmarkMenu |
	unmarkMenu := self newMenu.
	markerDropList listItems
		do: [ :listItem | 
			| color |
			color := listItem key.
			((markers at: color ifAbsent: [ #() ]) includes: aGolapVertex data)
				ifTrue: [ unmarkMenu
						addItem: [ :menuItem | 
							menuItem
								name: '';
								icon: (self iconForCircleColor: color);
								action: [ self remove: aGolapVertex fromMarker: color ] ] ] ].
	^ unmarkMenu
]

{ #category : #menu }
GolapItemList >> unmarkSelectionsMenu [
	| markMenu |
	markMenu := self newMenu.
	markerDropList listItems
		do: [ :listItem | 
			| color |
			color := listItem key.
			color isSymbol
				ifFalse: [ markMenu
						addItem: [ :item | 
							item
								name: '';
								icon: (self iconForCircleColor: color);
								action: [ self removeSelectionsFromMarker: color ] ] ] ].
	^ markMenu
]

{ #category : #drawing }
GolapItemList >> updateGlobalImage [

	self golapDo: [ :g | g updateGlobalImage ]
]

{ #category : #drawing }
GolapItemList >> updateGlobalImageAfter: aBlock [

	self golapDo: [ :g | g updateGlobalImageAfter: aBlock ]
]

{ #category : #drawing }
GolapItemList >> updateGlobalImageAfter: aBlock layout: aBoolean [

	self golapDo: [ :g | 
		g updateGlobalImageAfter: aBlock layout: aBoolean ]
]

{ #category : #updating }
GolapItemList >> updateVertexList [

	| vertices selectedMarker |
	self modelDo: [ :model | 
		vertices := model vertices keys asArray.
		selectedMarker := markerDropList selectedItem ifNil: [ nil -> '' ].
		markers at: selectedMarker key ifPresent: [ :markedIds | 
			vertices := vertices select: [ :id | 
				            markedIds anySatisfy: [ :m | 
					            (model vertexAt: id) hasData: m ] ] ].
		vertexList items: (vertices asSortedCollection: [ :id | 
				 [ model valueAtVertex: (model vertexAt: id) ]
					 on: Error
					 do: [ :ex | 0 ] ] descending) ]
]

{ #category : #private }
GolapItemList >> vertexList [

	^ vertexList
]

{ #category : #menu }
GolapItemList >> vertexListMenu [
	| menu selectedVertex |
	menu := self newMenu.
	selectedVertex := self model
		vertexAt: (vertexList selection selectedItem ifNil: [ ^ menu ])
		ifAbsent: [ ^ menu ].
	(self markMenu: selectedVertex)
		ifNotNil: [ :submenu | 
			menu
				addItem: [ :item | 
					item
						name: 'mark';
						subMenu: submenu ] ].
	(self unmarkMenu: selectedVertex)
		ifNotNil: [ :submenu | 
			menu
				addItem: [ :item | 
					item
						name: 'unmark';
						subMenu: submenu ] ].
	(golap includesPin: selectedVertex)
		ifTrue: [ menu
				addItem: [ :item | 
					item
						name: 'Unpin';
						action: [ golap togglePin: selectedVertex ] ] ]
		ifFalse: [ menu
				addItem: [ :item | 
					item
						name: 'Pin';
						action: [ golap togglePin: selectedVertex ] ] ].
	menu
		addItem: [ :item | 
			item
				name: 'Show info';
				action: [ golap showItemView: selectedVertex ] ].
	^ menu
]

{ #category : #accessing }
GolapItemList >> vertices [
	^ golap ifNotNil: #vertices
]
