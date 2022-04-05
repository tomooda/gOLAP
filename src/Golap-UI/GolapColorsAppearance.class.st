Class {
	#name : #GolapColorsAppearance,
	#superclass : #SpPresenter,
	#instVars : [
		'normalColor',
		'selectionColor',
		'retreatingColor',
		'decliningColor',
		'freshColor',
		'growingColor',
		'vertexColors',
		'nameList',
		'colorList',
		'nilIcon',
		'lastPattern',
		'golap',
		'positivePolishColor',
		'negativePolishColor'
	],
	#classVars : [
		'NamedColors'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #colors }
GolapColorsAppearance class >> colorAt: aSymbol [
	^ self colorMap at: aSymbol ifAbsent: [ nil ]
]

{ #category : #accessing }
GolapColorsAppearance class >> colorMap [
	^ NamedColors
		ifNil: [ NamedColors := OrderedDictionary new
				at: nil put: nil;
				at: #gray put: Color gray;
				at: #black put: Color black;
				at: #red put: Color red;
				at: #darkRed put: Color red muchDarker;
				at: #blue put: Color blue;
				at: #darkBlue put: Color blue muchDarker;
				at: #green put: Color green;
				at: #darkGreen put: Color green muchDarker;
				at: #magenta put: Color magenta;
				at: #darkMagenta put: Color magenta muchDarker;
				at: #cyan put: Color cyan;
				at: #darkCyan put: Color cyan muchDarker;
				at: #yellow put: Color yellow;
				at: #darkYellow put: Color yellow darker;
				yourself ]
]

{ #category : #colors }
GolapColorsAppearance class >> colorNames [
	^ self colorMap keys
]

{ #category : #specs }
GolapColorsAppearance class >> defaultSpec [
	<spec>
	^ SpBoxLayout newHorizontal
		add: #nameList width: 140;
		add: #colorList width: 140
]

{ #category : #'instance creation' }
GolapColorsAppearance class >> on: aGolap [
	^ self new
		setGolap: aGolap;
		yourself
]

{ #category : #'accessing-widgets' }
GolapColorsAppearance >> colorList [
	^ colorList
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> colorSelectors [

	^ #( normalColor selectionColor #positivePolishColor
	     #negativePolishColor growingColor decliningColor freshColor
	     retreatingColor )
]

{ #category : #accessing }
GolapColorsAppearance >> colors [
	^ {nil.
	Color gray.
	Color black.
	Color red.
	Color red muchDarker.
	Color blue.
	Color blue muchDarker.
	Color green.
	Color green muchDarker.
	Color magenta.
	Color magenta muchDarker.
	Color cyan.
	Color cyan muchDarker.
	Color yellow.
	Color yellow muchDarker}
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> decliningColor [
	^ decliningColor
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> decliningColor: aColor [
	self updateGlobalImageAfter: [ decliningColor := aColor ]
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> freshColor [
	^ freshColor
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> freshColor: aColor [
	self updateGlobalImageAfter: [ freshColor := aColor ]
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> growingColor [
	^ growingColor
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> growingColor: aColor [
	self updateGlobalImageAfter: [ growingColor := aColor ]
]

{ #category : #accessing }
GolapColorsAppearance >> iconExtent [
	^ 30 @ 14
]

{ #category : #accessing }
GolapColorsAppearance >> iconFor: aSymbol [

	^ self iconForColor: (golap ifNotNil: [ golap perform: aSymbol ])
]

{ #category : #accessing }
GolapColorsAppearance >> iconForColor: aColor [
	^ aColor
		ifNotNil: [ | icon |
			icon := Form extent: self iconExtent depth: 32.
			icon getCanvas
				fillColor: aColor;
				frameRectangle: (0 @ 0 extent: icon extent - (1 @ 1))
					width: 2
					color: Color black.
			icon ]
		ifNil: [ self nilIcon ]
]

{ #category : #initialization }
GolapColorsAppearance >> initialExtent [
	^ 500@250
]

{ #category : #initialization }
GolapColorsAppearance >> initialize [
	super initialize.
	normalColor := Color gray.
	selectionColor := Color black.
	positivePolishColor := Color cyan muchDarker.
	negativePolishColor := Color cyan.
	vertexColors := OrderedCollection new.
	freshColor := Color blue.
	growingColor := Color blue muchDarker.
	decliningColor := Color red muchDarker.
	retreatingColor := Color red
]

{ #category : #initialization }
GolapColorsAppearance >> initializePresenters [

	nameList := self newList
		            display: [ :item | self nameForColorSelector: item ];
		            displayIcon: [ :item | self iconFor: item ];
		            whenSelectionChangedDo: [ self updateSelectedName ];
		            yourself.
	colorList := self newList
		             displayIcon: [ :item | self iconForColor: item ];
		             display: [ :item | '' ];
		             whenSelectionChangedDo: [ self updateSelectedColor ];
		             yourself.
	self whenBuiltDo: [ :w | 
		| f |
		f := TextStyle defaultFont.
		w widget allMorphsDo: [ :m | 
			(m respondsTo: #font:) ifTrue: [ m font: f ] ] ]
]

{ #category : #initialization }
GolapColorsAppearance >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter title: 'Colors'
]

{ #category : #accessing }
GolapColorsAppearance >> nameForColorSelector: aSymbol [
	aSymbol = #normalColor
		ifTrue: [ ^ '通常' ].
	aSymbol = #positivePolishColor
		ifTrue: [ ^ '+研磨' ].
	aSymbol = #negativePolishColor
		ifTrue: [ ^ '-研磨' ].
	aSymbol = #decliningColor
		ifTrue: [ ^ '↘' ].
	aSymbol = #freshColor
		ifTrue: [ ^ '↑' ].
	aSymbol = #growingColor
		ifTrue: [ ^ '↗' ].
	aSymbol = #retreatingColor
		ifTrue: [ ^ '↓' ].
	aSymbol = #selectionColor
		ifTrue: [ ^ '選択' ].
	^ aSymbol
]

{ #category : #'accessing-widgets' }
GolapColorsAppearance >> nameList [
	^ nameList
]

{ #category : #accessing }
GolapColorsAppearance >> negativePolishColor [

	^ negativePolishColor
]

{ #category : #accessing }
GolapColorsAppearance >> negativePolishColor: aColor [

	negativePolishColor := aColor
]

{ #category : #accessing }
GolapColorsAppearance >> nilIcon [
	^ nilIcon
		ifNil: [ | icon |
			icon := Form extent: self iconExtent depth: 32.
			icon getCanvas
				fillColor: Color white;
				line: 0 @ 0
					to: icon extent
					width: 2
					color: Color red;
				frameRectangle: (0 @ 0 extent: icon extent - (1 @ 1))
					width: 2
					color: Color black.
			nilIcon := icon ]
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> normalColor [
	^ normalColor
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> normalColor: aColor [
	self updateGlobalImageAfter: [ normalColor := aColor ]
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> normalColorFor: aGolapVertex [
	vertexColors
		do: [ :triple | 
			(triple second matches: aGolapVertex name)
				ifTrue: [ ^ triple third ] ].
	^ self normalColor
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> positivePolishColor [
	^ positivePolishColor
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> positivePolishColor: aColor [
	self updateGlobalImageAfter: [ positivePolishColor := aColor ]
]

{ #category : #snapshot }
GolapColorsAppearance >> restore: aStream [

	(NeoJSONReader on: aStream) next keysAndValuesDo: [ 
		:colorSelector 
		:colorHexString | 
		self
			perform: (colorSelector , ':') asSymbol
			with:
			(colorHexString ifNotNil: [ Color fromHexString: colorHexString ]) ]
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> retreatingColor [
	^ retreatingColor 
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> retreatingColor: aColor [
	self updateGlobalImageAfter: [ retreatingColor := aColor ]
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> selectionColor [
	^ selectionColor 
]

{ #category : #'accessing-colors' }
GolapColorsAppearance >> selectionColor: aColor [
	self updateGlobalImageAfter: [ selectionColor := aColor ]
]

{ #category : #private }
GolapColorsAppearance >> setGolap: aGolap [
	golap := aGolap.
	self updateNameList
]

{ #category : #snapshot }
GolapColorsAppearance >> snapshot [

	golap snapshotColorsAppearance: [ :stream | 
		self snapshotInto: stream ]
]

{ #category : #snapshot }
GolapColorsAppearance >> snapshotInto: aStream [

	| json |
	json := (self colorSelectors collect: [ :selector | 
		         selector
		         ->
		         ((self perform: selector asSymbol) ifNotNil: #asHexString) ])
		        asOrderedDictionary.
	(NeoJSONWriter on: aStream) nextPut: json
]

{ #category : #drawing }
GolapColorsAppearance >> updateGlobalImageAfter: aBlock [
	^ golap ifNotNil: [ golap updateGlobalImageAfter: aBlock ]
]

{ #category : #drawing }
GolapColorsAppearance >> updateGlobalImageAfter: aBlock layout: aBoolean [
	^ golap ifNotNil: [ golap updateGlobalImageAfter: aBlock layout: aBoolean ]
]

{ #category : #private }
GolapColorsAppearance >> updateNameList [
	nameList items: self colorSelectors
]

{ #category : #private }
GolapColorsAppearance >> updateSelectedColor [

	nameList selection selectedItem ifNotNil: [ :item | 
		self
			perform: (item , ':') asSymbol
			with: colorList selection selectedItem.
		self updateNameList.
		nameList selectItem: item.
		self snapshot.
		golap updateGlobalImage ]
]

{ #category : #private }
GolapColorsAppearance >> updateSelectedName [

	nameList selection selectedItem
		ifNil: [ colorList items: #(  ) ]
		ifNotNil: [ :item | 
			golap ifNotNil: [ 
				| color |
				color := golap perform: item.
				colorList
					items: self colors;
					selectItem: color ] ]
]
