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
GolapItemList >> add: aGolapNode toMarker: aColor [

	self updateGlobalImageAfter: [
			golap model ensureMarker: aColor.
			aGolapNode addMarker: aColor.
			markerDropList items do: [ :assoc |
					assoc key = aColor ifTrue: [
							| patterns regexs |
							patterns := (assoc value substrings: ',')
								            collect: #trim
								            thenSelect: #notEmpty.
							regexs := patterns collect: [ :pattern |
								          self regexFor: pattern ].
							(regexs anySatisfy: [ :regex | regex matches: aGolapNode name ])
								ifFalse: [ patterns := patterns copyWith: aGolapNode name ].
							assoc value: (',' join: patterns) ] ].
			self currentMarker: aColor.
			self updateItemsList ]
]

{ #category : 'adding' }
GolapItemList >> addAll: aCollectionOfGolapNode toMarker: aColor [

	self updateGlobalImageAfter: [
			golap model ensureMarker: aColor.
			aCollectionOfGolapNode do: [ :node | node addMarker: aColor ].
			markerDropList items do: [ :assoc |
					assoc key = aColor ifTrue: [
							| patterns regexs |
							patterns := (assoc value substrings: ',')
								            collect: #trim
								            thenSelect: #notEmpty.
							regexs := patterns collect: [ :pattern |
								          self regexFor: pattern ].
							aCollectionOfGolapNode do: [ :node |
									(regexs anySatisfy: [ :regex | regex matches: node name ])
										ifFalse: [ patterns := patterns copyWith: node name ] ].
							assoc value: (',' join: patterns) ] ].
			self currentMarker: aColor.
			self updateItemsList ]
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

	| items |
	golap model ensureMarker: aColor.
	markerDropList listItems do: [ :assoc |
			assoc key = aColor ifTrue: [
					markerDropList selectItem: assoc.
					^ self ] ].
	items := markerDropList listItems.
	markerDropList
		items: (items copyFrom: 1 to: items size - 1) , {
					(aColor -> '').
					items last };
		selectItem: aColor -> ''
]

{ #category : 'adding' }
GolapItemList >> addSelectionsToMarker: aColor [

	self golapDo: [ :g | self addAll: g selections toMarker: aColor ]
]

{ #category : 'snapshot' }
GolapItemList >> asJSON [

	^ {
		  ('marker' -> (self currentMarker ifNotNil: #asHexString)).
		  ('markerFilters'
		   -> (markerDropList items collect: [ :colorAndPatternString |
					    (colorAndPatternString key
						     ifNotNil: #asHexString
						     ifNil: [ '' ]) -> colorAndPatternString value ])
				   asDictionary) } asDictionary
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
GolapItemList >> currentMarker [
	^ markerDropList selectedItem ifNotNil: #key
]

{ #category : 'accessing-markers' }
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

{ #category : 'accessing' }
GolapItemList >> golap: aGolap [
	golap := aGolap
]

{ #category : 'accessing' }
GolapItemList >> golapDo: aBlock [

	^ golap ifNotNil: aBlock
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
										                  self updateItemsList.
										                  self updateGlobalImage ] ] ];
		                  yourself.
	lastSelectedMarkerIndex := 0.
	queryField := self newTextInput whenSubmitDo: [ :txt |
			              | text |
			              text := queryField text asString trim.
			              self updateGlobalImageAfter: [
					              | selectedMarker nodes |
					              selectedMarker := markerDropList selectedItem.
					              selectedMarker value: text.
					              nodes := OrderedCollection new.
					              text ifNotEmpty: [ :q |
							              | regexs |
							              regexs := (q substrings: ',') collect: [ :pattern |
								                        self regexFor: pattern trim ].
							              nodes := self nodes select: [ :v |
								                       regexs anySatisfy: [ :regex |
									                       regex matches: v name ] ] ].
					              selectedMarker key ifNotNil: [ :marker |
							              self nodes do: [ :node |
								              node removeMarker: selectedMarker key ].
							              golap model ensureMarker: selectedMarker key.
							              nodes do: [ :node |
								              node addMarker: selectedMarker key ] ] ].
			              self updateItemsList ].
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
	markerDropList listItems do: [ :listItem |
			| color |
			color := listItem key.
			color isSymbol ifFalse: [
					(aGolapNode hasMarker: color) ifFalse: [
							markMenu addItem: [ :menuItem |
									menuItem
										name: '';
										icon: (self iconForCircleColor: color);
										action: [ self add: aGolapNode toMarker: color ] ] ] ] ].
	^ markMenu
]

{ #category : 'menu' }
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

{ #category : 'accessing-markers' }
GolapItemList >> markedNodes [

	^ Array streamContents: [ :stream |
			  self model
				  nodesWithMarker: self currentMarker
				  do: [ :node | stream nextPut: node ] ]
]

{ #category : 'private' }
GolapItemList >> markerDropList [
	^ markerDropList
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
					(golap isReferenceNode: selectedNode)
						ifTrue: [
								group addItem: [ :item |
										item
											name: 'remove from reference';
											action: [ golap removeReferenceNode: selectedNode ] ] ]
						ifFalse: [
								(golap isLockedNode: selectedNode)
									ifTrue: [
											group
												addItem: [ :item |
														item
															name: 'be auto layouted';
															action: [ golap unlockNode: selectedNode ] ];
												addItem: [ :item |
														item
															name: 'add to reference';
															action: [
																	golap
																		unlockNode: selectedNode;
																		addReferenceNode: selectedNode ] ] ]
									ifFalse: [
											group addItem: [ :item |
													item
														name: 'add to reference';
														action: [ golap addReferenceNode: selectedNode ] ] ] ] ] ].

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
GolapItemList >> remove: aGolapNode fromMarker: aColor [

	self updateGlobalImageAfter: [
			aGolapNode removeMarker: aColor.
			markerDropList items do: [ :assoc |
					assoc key = aColor ifTrue: [
							| patterns |
							patterns := (assoc value substrings: ',')
								            collect: #trim
								            thenSelect: #notEmpty.
							patterns := patterns copyWithout: aGolapNode name.
							assoc value: (',' join: patterns) ] ].
			self currentMarker: aColor.
			self updateItemsList ]
]

{ #category : 'removing' }
GolapItemList >> removeAll: aCollectionOfGolapNode fromMarker: aColor [

	self updateGlobalImageAfter: [
			aCollectionOfGolapNode do: [ :node | node removeMarker: aColor ].
			markerDropList items do: [ :assoc |
					assoc key = aColor ifTrue: [
							| patterns |
							patterns := (assoc value substrings: ',')
								            collect: #trim
								            thenSelect: #notEmpty.
							patterns := patterns reject: [ :pattern |
								            aCollectionOfGolapNode anySatisfy: [ :node |
									            node name = pattern ] ].
							assoc value: (',' join: patterns) ] ].
			self currentMarker: aColor.
			self updateItemsList ]
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
	markerDropList listItems do: [ :listItem |
			| color |
			color := listItem key.
			(aGolapNode hasMarker: color) ifTrue: [
					unmarkMenu addItem: [ :menuItem |
							menuItem
								name: '';
								icon: (self iconForCircleColor: color);
								action: [ self remove: aGolapNode fromMarker: color ] ] ] ].
	^ unmarkMenu
]

{ #category : 'menu' }
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

	| nodes |
	self modelDo: [ :model |
			nodes := model nodes asArray select: [ :node |
				         self showsNode: node ].
			self currentMarker
				ifNotNil: [ :marker |
				nodes := nodes select: [ :node | node hasMarker: marker ] ]
				ifNil: [ nodes := self filter: nodes ].
			nodeList
				items: ((nodes asSortedCollection:
						  [ :node | model valueAtNode: node ] descending) collect: #id)
				selectItems: nodeList selectedItems ]
]
