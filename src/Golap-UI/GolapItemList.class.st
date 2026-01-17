Class {
	#name : 'GolapItemList',
	#superclass : 'SpPresenter',
	#instVars : [
		'golap',
		'markerDropList',
		'lastSelectedMarkerIndex',
		'queryField',
		'presetQueryButton',
		'showsAllItemsCheckBox',
		'nodeList'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'adding' }
GolapItemList >> add: aGolapNode toMarker: aGolapMarker [

	aGolapMarker addNode: aGolapNode.
	self currentMarker: aGolapMarker
]

{ #category : 'adding' }
GolapItemList >> addAll: aCollectionOfGolapNode toMarker: aGolapMarker [

	aCollectionOfGolapNode do: [ :node | aGolapMarker addNode: node ].
	self currentMarker: aGolapMarker
]

{ #category : 'accessing-markers' }
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

{ #category : 'accessing-markers' }
GolapItemList >> addMarkerColor: aColor [

	| colorHexString items newMarker |
	colorHexString := aColor asHexString.
	markerDropList listItems do: [ :marker |
			marker colorHexString = colorHexString ifTrue: [
				^ self currentMarker: marker ] ].
	items := markerDropList listItems.
	newMarker := GolapColorMarker colorHexString: colorHexString.
	markerDropList
		items: (items copyFrom: 1 to: items size - 1) , {
					newMarker.
					items last };
		selectItem: newMarker
]

{ #category : 'adding' }
GolapItemList >> addSelectionsToMarker: aColor [

	self golapDo: [ :g | self addAll: g selections toMarker: aColor ]
]

{ #category : 'accessing-markers' }
GolapItemList >> allMarkerColors [

	^ markerDropList items
		  collect: #color
		  thenSelect: [ :marker | marker notNil ]
]

{ #category : 'snapshot' }
GolapItemList >> asJSON [

	^ {
		  ('markers' -> (markerDropList items collect: #asJSON)).
		  ('markers-selectedIndex' -> markerDropList selectedIndex) }
		  asDictionary
]

{ #category : 'layout' }
GolapItemList >> buttonHeight [

	^ self class buttonHeight
]

{ #category : 'accessing' }
GolapItemList >> colorFor: aGolapNode [

	^ (aGolapNode notNil and: [
		   self showsAllItems and: [ (golap showsNode: aGolapNode) not ] ])
		  ifTrue: [ Color lightGray ]
		  ifFalse: [ Color black ]
]

{ #category : 'accessing-markers' }
GolapItemList >> colorMarkers [

	^ markerDropList items select: #isColorMarker
]

{ #category : 'enumerating' }
GolapItemList >> colorMarkersAndNodesDo: aBlock [

	self golapModelDo: [ :golapModel |
			markerDropList items do: [ :marker |
					aBlock value: marker value: (Array streamContents: [ :stream |
								 marker nodeIdsDo: [ :id |
										 (golapModel nodeAt: id ifAbsent: [ nil ]) ifNotNil: [ :node |
											 stream nextPut: node ] ] ]) ] ]
]

{ #category : 'accessing-markers' }
GolapItemList >> currentMarker [

	^ markerDropList selectedItem
]

{ #category : 'accessing-markers' }
GolapItemList >> currentMarker: aGolapMarker [

	markerDropList selectItem: aGolapMarker.
	self updateGlobalImage
]

{ #category : 'layout' }
GolapItemList >> defaultLayout [

	<spec>
	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: markerDropList width: 50;
				   add: queryField;
				   add: presetQueryButton width: 20)
		  height: self buttonHeight;
		  add: showsAllItemsCheckBox height: self buttonHeight;
		  add: nodeList
]

{ #category : 'testing' }
GolapItemList >> filter: aCollectionOfGolapNode [

	^ queryField text asString trim
		  ifNotEmpty: [ :q |
				  | regexs |
				  regexs := (q substrings: ',') collect: [ :pattern |
					            self regexFor: pattern trim ].
				  aCollectionOfGolapNode select: [ :v |
					  regexs anySatisfy: [ :regex | regex matches: v name ] ] ]
		  ifEmpty: [ aCollectionOfGolapNode ]
]

{ #category : 'snapshot' }
GolapItemList >> fromJSON: aDictionary [

	aDictionary
		at: 'markers' ifPresent: [ :array |
				markerDropList items: (array collect: [ :dict |
									 (GolapAbstractMarker fromJSON: dict)
										 updateIn: self;
										 yourself ]) ];
		at: 'markers-selectedIndex'
		ifPresent: [ :integer | markerDropList selectIndex: integer ]
]

{ #category : 'accessing' }
GolapItemList >> golap [

	^ golap
]

{ #category : 'accessing' }
GolapItemList >> golap: aGolap [
	golap := aGolap
]

{ #category : 'accessing' }
GolapItemList >> golapDo: aBlock [

	^ golap ifNotNil: aBlock
]

{ #category : 'accessing' }
GolapItemList >> golapModelDo: aBlock [

	golap model ifNotNil: aBlock
]

{ #category : 'private' }
GolapItemList >> iconForCircleColor: aColor [

	| icon canvas |
	icon := Form extent: 16 @ 16 depth: 32.
	canvas := icon getCanvas.
	canvas fillColor: Color transparent.
	aColor ifNotNil: [ 
		canvas frameOval: (1 @ 1 corner: 14 @ 14) width: 2 color: aColor ].
	^ icon
]

{ #category : 'private' }
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

{ #category : 'initialization' }
GolapItemList >> initializePresenters [

	markerDropList := self newDropList
		                  items: {
				                  GolapNoMarker new.
				                  (GolapColorMarker colorHexString:
						                   Color red asHexString).
				                  (GolapColorMarker colorHexString:
						                   Color yellow darker asHexString).
				                  (GolapColorMarker colorHexString:
						                   Color green asHexString).
				                  (GolapColorMarker colorHexString:
						                   Color blue asHexString).
				                  GolapAddMarker new };
		                  display: [ :marker | '' ];
		                  displayIcon: [ :marker | marker icon ];
		                  whenSelectedItemChangedDo: [ :marker |
				                  marker ifNotNil: [
							                  marker activatedIn: self.
							                  self updateGlobalImage ] ];
		                  yourself.
	lastSelectedMarkerIndex := 0.
	queryField := self newTextInput
		              whenSubmitDo: [ :text |
				              markerDropList selectedItem ifNotNil: [ :marker |
						              marker queryString: text asString trim ] ];
		              yourself.
	presetQueryButton := self newButton
		                     icon: (Smalltalk ui icons iconNamed: #back);
		                     action: [ golap openPresetQueryDialog ];
		                     yourself.
	showsAllItemsCheckBox := self newCheckBox
		                         label: '全商品を表示する';
		                         state: false;
		                         whenChangedDo: [ self updateItemsList ];
		                         yourself.
	nodeList := self newTable
		            beMultipleSelection;
		            disableSearch;
		            addColumn: (SpStringTableColumn new
				             width: 80;
				             displayColor: [ :id |
					             self colorFor: (self model nodeAt: id) ];
				             evaluated: [ :id |
						             self simpleStringFor:
								             (self model valueAtNode: (self model nodeAt: id)) ]);
		            addColumn: (SpStringTableColumn new
				             displayColor: [ :id |
					             self colorFor: (self model nodeAt: id) ];
				             evaluated: [ :id | (self model nodeAt: id) name ]);
		            contextMenu: [ self nodeListMenu ];
		            whenSelectionChangedDo: [
				            self updateGlobalImageAfter: [
						            golap setSelections: nodeList selectedItems.
						            golap updateItemView ] ];
		            yourself.
	nodeList whenBuiltDo: [
			nodeList withAdapterDo: [ :a |
					a widgetDo: [ :w |
							w
								secondarySelectionColor:
									w selectionColor lighter lighter lighter;
								allowsDeselection: true ] ] ]
]

{ #category : 'menu' }
GolapItemList >> markMenu: aGolapNode [

	| markMenu |
	markMenu := self newMenu.
	markerDropList listItems do: [ :marker |
			(marker includesNode: aGolapNode) ifFalse: [
					markMenu addItem: [ :menuItem |
							menuItem
								name: '';
								icon: marker icon;
								action: [ self add: aGolapNode toMarker: marker ] ] ] ].
	^ markMenu
]

{ #category : 'menu' }
GolapItemList >> markSelectionsMenu [

	| markMenu |
	markMenu := self newMenu.
	markerDropList items do: [ :marker |
			marker isColorMarker ifTrue: [
					markMenu addItem: [ :menuItem |
							menuItem
								name: '';
								icon: marker icon;
								action: [ self addSelectionsToMarker: marker ] ] ] ].
	^ markMenu
]

{ #category : 'accessing-markers' }
GolapItemList >> markedNodes [

	| marker |
	marker := self currentMarker.
	^ Array streamContents: [ :stream |
			  self model nodesDo: [ :node |
				  (marker includesNode: node) ifTrue: [ stream nextPut: node ] ] ]
]

{ #category : 'private' }
GolapItemList >> markerDropList [

	^ markerDropList
]

{ #category : 'accessing-markers' }
GolapItemList >> markersAtNode: aGolapNode do: aBlock [

	markerDropList items do: [ :marker |
			(marker isColorMarker and: [ marker includesNode: aGolapNode ])
				ifTrue: [ aBlock value: marker ] ]
]

{ #category : 'accessing' }
GolapItemList >> model [

	^ golap ifNotNil: #model
]

{ #category : 'updating' }
GolapItemList >> modelChanged [

	
]

{ #category : 'accessing' }
GolapItemList >> modelDo: aBlock [

	^ self golapDo: [ :g | g model ifNotNil: aBlock ]
]

{ #category : 'private' }
GolapItemList >> nodeList [

	^ nodeList
]

{ #category : 'menu' }
GolapItemList >> nodeListMenu [

	| menu selectedNode |
	menu := self newMenu.
	selectedNode := self model
		                nodeAt:
		                (nodeList selection selectedItem ifNil: [ ^ menu ])
		                ifAbsent: [ ^ menu ].
	menu addGroup: [ :group |
			(self markMenu: selectedNode) ifNotNil: [ :submenu |
					group addItem: [ :item |
							item
								name: 'mark';
								subMenu: submenu ] ].
			(self unmarkMenu: selectedNode) ifNotNil: [ :submenu |
					group addItem: [ :item |
							item
								name: 'unmark';
								subMenu: submenu ] ].
			nodeList selectedItems ifNotEmpty: [
					group
						addItem: [ :item |
								item
									name: 'Mark selections';
									subMenu: self markSelectionsMenu ];
						addItem: [ :item |
								item
									name: 'Unmark selections';
									subMenu: self unmarkSelectionsMenu ] ] ].

	selectedNode ifNotNil: [
			menu addGroup: [ :group |
					(golap model isReferenceNode: selectedNode)
						ifTrue: [
								group addItem: [ :item |
										item
											name: 'remove from reference';
											action: [ golap removeReferenceNode: selectedNode ] ] ]
						ifFalse: [
								group addItem: [ :item |
										item
											name: 'add to reference';
											action: [ golap addReferenceNode: selectedNode ] ] ] ] ].

	menu addGroup: [ :group |
			(golap includesPin: selectedNode)
				ifTrue: [
						group addItem: [ :item |
								item
									name: 'Unpin';
									action: [ golap togglePin: selectedNode ] ] ]
				ifFalse: [
						group addItem: [ :item |
								item
									name: 'Pin';
									action: [ golap togglePin: selectedNode ] ] ] ].
	menu addGroup: [ :group |
			group addItem: [ :item |
					item
						name: 'Show info';
						action: [ golap showItemView: selectedNode ] ] ].
	^ menu
]

{ #category : 'accessing' }
GolapItemList >> nodes [
	^ golap ifNotNil: #nodes
]

{ #category : 'private' }
GolapItemList >> queryField [

	^ queryField
]

{ #category : 'private' }
GolapItemList >> regexFor: aString [
	| regex |
	regex := #('\' '.' '[' ']' '(' ')' '!' '+')
		inject: aString
		into: [ :p :special | p copyReplaceAll: special with: '\' , special ].
	^ ((regex copyReplaceAll: '*' with: '.*')
		copyReplaceAll: '?'
		with: '[ -~]+') asRegex
]

{ #category : 'removing' }
GolapItemList >> remove: aGolapNode fromMarker: aGolapMarker [

	aGolapMarker removeNode: aGolapNode.
	self currentMarker: aGolapMarker
]

{ #category : 'removing' }
GolapItemList >> removeAll: aCollectionOfGolapNode fromMarker: aGolapMarker [

	aCollectionOfGolapNode do: [ :node | aGolapMarker removeNode: node ].
	self currentMarker: aGolapMarker
]

{ #category : 'removing' }
GolapItemList >> removeSelectionsFromMarker: aColor [
	self removeAll: golap selections fromMarker: aColor
]

{ #category : 'snapshot' }
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
								markerDropList selectIndex: lastSelectedMarkerIndex ] ].
			self updateItemsList ]
]

{ #category : 'accessing' }
GolapItemList >> selectedItem [

	^ nodeList selection selectedItem
]

{ #category : 'accessing' }
GolapItemList >> selectedItems: aCollectionOfString [

	nodeList selectItems: aCollectionOfString
]

{ #category : 'testing' }
GolapItemList >> showsAllItems [

	^ showsAllItemsCheckBox state = true
]

{ #category : 'testing' }
GolapItemList >> showsNode: aGolapNode [

	^ self showsAllItems or: [ golap showsNode: aGolapNode ]
]

{ #category : 'private' }
GolapItemList >> simpleStringFor: aNumber [

	^ golap simpleStringFor: aNumber
]

{ #category : 'snapshot' }
GolapItemList >> snapshot [

	golap snapshotItemList: [ :stream | self snapshotInto: stream ]
]

{ #category : 'snapshot' }
GolapItemList >> snapshotColor: aColor [

	^ aColor ifNil: [ '' ] ifNotNil: [ 
		  aColor isColor
			  ifTrue: [ aColor asHexString ]
			  ifFalse: [ aColor ] ]
]

{ #category : 'snapshot' }
GolapItemList >> snapshotInto: aStream [

	| json |
	json := OrderedDictionary new.
	json at: 'selectedMarkerIndex' put: lastSelectedMarkerIndex.
	json
		at: 'markerFilters'
		put: (markerDropList items collect: [ :colorAndPatternString |
					 (self snapshotColor: colorAndPatternString key)
					 -> colorAndPatternString value ]) asOrderedDictionary.
	(NeoJSONWriter on: aStream) nextPut: json
]

{ #category : 'menu' }
GolapItemList >> unmarkMenu: aGolapNode [

	| unmarkMenu |
	unmarkMenu := self newMenu.
	markerDropList items do: [ :marker |
			(marker isColorMarker and: [ marker includesNode: aGolapNode ])
				ifTrue: [
						unmarkMenu addItem: [ :menuItem |
								menuItem
									name: '';
									icon: marker icon;
									action: [ self remove: aGolapNode fromMarker: marker ] ] ] ].
	^ unmarkMenu
]

{ #category : 'menu' }
GolapItemList >> unmarkSelectionsMenu [

	| markMenu |
	markMenu := self newMenu.
	markerDropList items do: [ :marker |
			marker isColorMarker ifTrue: [
					markMenu addItem: [ :item |
							item
								name: '';
								icon: marker icon;
								action: [ self removeSelectionsFromMarker: marker ] ] ] ].
	^ markMenu
]

{ #category : 'drawing' }
GolapItemList >> updateGlobalImage [

	self golapDo: [ :g | g updateGlobalImage ]
]

{ #category : 'drawing' }
GolapItemList >> updateGlobalImageAfter: aBlock [

	self golapDo: [ :g | g updateGlobalImageAfter: aBlock ]
]

{ #category : 'drawing' }
GolapItemList >> updateGlobalImageAfter: aBlock layout: aBoolean [

	self golapDo: [ :g | 
		g updateGlobalImageAfter: aBlock layout: aBoolean ]
]

{ #category : 'updating' }
GolapItemList >> updateItemsList [

	markerDropList items do: [ :marker | marker updateIn: self ].
	markerDropList selectedItem ifNotNil: [ :marker |
		marker activatedIn: self ]
]
