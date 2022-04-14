Class {
	#name : #GolapOverviewRenderer,
	#superclass : #GolapRenderer,
	#instVars : [
		'layouter',
		'mapScale',
		'mapOffset',
		'viewScale',
		'viewOffset',
		'labelBoxes',
		'activeImage',
		'inactiveImage',
		'activeMap',
		'inactiveMap'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #drawing }
GolapOverviewRenderer >> drawEdgeLabelFor: aGolapEdge at: aPoint color: aColor on: aCanvas [
	| string w h rect |
	self
		modelDo: [ :model | 
			string := String
				streamContents: [ :stream | 
					stream
						space;
						nextPutAll: (self simpleStringFor: (model valueAtEdge: aGolapEdge)).
					golap selectedFrontDimension
						ifNotNil: [ :frontModel | 
							golap selectedBaseDimension
								ifNotNil: [ :baseModel | 
									stream
										nextPutAll: '=';
										nextPutAll:
											((frontModel
												edgeBetween: aGolapEdge vertex1 data
												and: aGolapEdge vertex2 data
												ifAbsent: [ frontModel
														hiddenEdgeBetween: aGolapEdge vertex1 data
														and: aGolapEdge vertex2 data
														ifAbsent: [ nil ] ])
												ifNotNil: [ :e | self simpleStringFor: (frontModel valueAtEdge: e) ]
												ifNil: [ '0' ]);
										nextPutAll: '-';
										nextPutAll:
											((baseModel
												edgeBetween: aGolapEdge vertex1 data
												and: aGolapEdge vertex2 data
												ifAbsent: [ baseModel
														hiddenEdgeBetween: aGolapEdge vertex1 data
														and: aGolapEdge vertex2 data
														ifAbsent: [ nil ] ])
												ifNotNil: [ :e | self simpleStringFor: (baseModel valueAtEdge: e) ]
												ifNil: [ '0' ]);
										space ] ] ].
			w := self font widthOfString: string.
			h := self font height.
			rect := Rectangle center: aPoint extent: w @ h.
			aCanvas fillRectangle: rect color: Color white.
			aCanvas frameRectangle: rect width: 1 color: Color black.
			aCanvas
				drawString: string
				at: aPoint - ((w // 2 + 1) @ (h // 2 + 1))
				font: self font
				color: aColor ]
]

{ #category : #drawing }
GolapOverviewRenderer >> drawEdgesOn: aCanvas [

	| scale maxValue lineScale |
	scale := self scale.
	self edgeScale < 1.0e-6 ifTrue: [ ^ self ].
	reallyVisibleEdges ifEmpty: [ ^ self ].
	maxValue := (reallyVisibleEdges
		             collect: [ :e | 
		             (golap model valueAtEdge: e) ifNotNil: #abs ]
		             thenSelect: [ :v | 
		             v notNil and: [ v isNaN not and: [ v isInfinite not ] ] ])
		            ifEmpty: [ 0 ]
		            ifNotEmpty: #max.
	lineScale := maxValue >= 1.0e-8
		             ifTrue: [ 5.0 / maxValue * self edgeScale ]
		             ifFalse: [ 2.0 ].
	reallyVisibleEdges do: [ :edge | 
		(golap model valueAtEdge: edge) ifNotNil: [ :v0 | 
			(self colorForEdge: edge) ifNotNil: [ :c | 
				| v p1 p2 str |
				v := v0.
				p1 := edge vertex1 asPoint * scale + viewOffset.
				p2 := edge vertex2 asPoint * scale + viewOffset.
				str := self simpleStringFor: v.
				(v notNil and: [ v isInfinite ]) ifTrue: [ 
					v := v > 0.0
						     ifTrue: [ maxValue * 2.0 ]
						     ifFalse: [ maxValue * -2.0 ] ].
				((golap includesSelection: edge vertex1) or: [ 
					 golap includesSelection: edge vertex2 ])
					ifTrue: [ 
						v isNaN ifFalse: [ 
							aCanvas
								line: p1
								to: p2
								width: v abs * lineScale + 2.0
								color: c ].
						self
							drawEdgeLabelFor: edge
							at: p1 + p2 / 2.0 + (5 @ 5)
							color: c
							on: aCanvas ]
					ifFalse: [ 
						| c0 |
						c0 := c alpha: 0.2.
						v isNaN ifFalse: [ 
							aCanvas
								line: p1
								to: p2
								width: v abs * lineScale + 2.0
								color: c0 ].
						aCanvas
							drawString: str
							at: p1 + p2 / 2.0 + (5 @ 5)
							font: self font
							color: c0 ] ] ] ].
	golap positivePolishColor ifNotNil: [ :color | 
		golap model positivePolishEdgesDo: [ :edge | 
			((reallyVisibleVertices includes: edge vertex1) and: [ 
				 reallyVisibleVertices includes: edge vertex2 ]) ifTrue: [ 
				| p1 p2 |
				p1 := edge vertex1 asPoint * scale + viewOffset.
				p2 := edge vertex2 asPoint * scale + viewOffset.
				aCanvas
					line: p1
					to: p2
					width: (((golap includesSelection: edge vertex1) or: [ 
							  golap includesSelection: edge vertex2 ])
							 ifTrue: [ 4 ]
							 ifFalse: [ 2 ])
					color: color ] ] ].
	golap negativePolishColor ifNotNil: [ :color | 
		golap model negativePolishEdgesDo: [ :edge | 
			((reallyVisibleVertices includes: edge vertex1) and: [ 
				 reallyVisibleVertices includes: edge vertex2 ]) ifTrue: [ 
				| p1 p2 |
				p1 := edge vertex1 asPoint * scale + viewOffset.
				p2 := edge vertex2 asPoint * scale + viewOffset.
				aCanvas
					line: p1
					to: p2
					width: (((golap includesSelection: edge vertex1) or: [ 
							  golap includesSelection: edge vertex2 ])
							 ifTrue: [ 4 ]
							 ifFalse: [ 1 ])
					color: color ] ] ].
	golap selectedEdges do: [ :edge | 
		edge data ifNotNil: [ 
			| c p1 p2 |
			c := Color black.
			p1 := edge vertex1 asPoint * scale + viewOffset.
			p2 := edge vertex2 asPoint * scale + viewOffset.
			aCanvas
				line: p1
				to: p2
				width: 2
				color: c.
			self
				drawEdgeLabelFor: edge
				at: p1 + p2 / 2.0 + (5 @ 5)
				color: c
				on: aCanvas ] ]
]

{ #category : #drawing }
GolapOverviewRenderer >> drawPinsOn: aCanvas [
	| scale |
	scale := self scale.
	golap
		pinsDo: [ :vertex | 
			| p |
			p := vertex asPoint * scale + viewOffset.
			aCanvas
				drawPolygon:
					{p.
					(p + (7 @ -12)).
					(p + (-7 @ -12))}
					fillStyle: Color red;
				fillOval: (p - (8 @ 21) extent: 16 @ 16) color: Color red;
				fillOval: (p - (3 @ 16) extent: 6 @ 6) color: Color white ]
]

{ #category : #drawing }
GolapOverviewRenderer >> drawSelectionsOn: aCanvas [
	| labelOffset scale newLabelBoxes |
	labelOffset := 15 @ (self font height * -0.5).
	scale := self scale.
	newLabelBoxes := Array new writeStream.
	golap
		selectedVerticesDo: [ :vertex | 
			(self colorForVertex: vertex)
				ifNotNil: [ :c | 
					| p lp |
					p := vertex asPoint * scale + viewOffset.
					lp := p
						+
							(((golap visibleEdges
								collect: [ :edge | 
									(edge peerOf: vertex)
										ifNil: [ 0 ]
										ifNotNil: [ :peer | peer x - vertex x ] ])
								ifEmpty: [ 0.0 ]
								ifNotEmpty: #sum) <= 0.0
								ifTrue: [ labelOffset ]
								ifFalse: [ (((self extentForName: vertex name) x + labelOffset x) * -1)
										@ labelOffset y ]).
					(self
						drawVertexLabelFor: vertex
						at: lp
						color: c
						fillColor: Color white
						on: aCanvas) ifNotNil: [ :box | newLabelBoxes nextPut: box -> vertex ] ] ].
	labelBoxes := newLabelBoxes contents
]

{ #category : #drawing }
GolapOverviewRenderer >> drawVertexLabelFor: aGolapVertex at: aPoint color: aColor fillColor: fillColor on: aCanvas [
	| box |
	box := nil.
	self
		modelDo: [ :model | 
			| deltaString nameExtent |
			deltaString := String
				streamContents: [ :stream | 
					stream
						space;
						nextPutAll: (self simpleStringFor: (model valueAtVertex: aGolapVertex)).
					golap selectedFrontDimension
						ifNotNil: [ :frontModel | 
							golap selectedBaseDimension
								ifNotNil: [ :baseModel | 
									stream
										nextPutAll: '=';
										nextPutAll:
											((frontModel vertexAt: aGolapVertex data ifAbsent: [ nil ])
												ifNotNil: [ :v | self simpleStringFor: (frontModel valueAtVertex: v) ]
												ifNil: [ '0' ]);
										nextPutAll: '-';
										nextPutAll:
											((baseModel vertexAt: aGolapVertex data ifAbsent: [ nil ])
												ifNotNil: [ :v | self simpleStringFor: (baseModel valueAtVertex: v) ]
												ifNil: [ '0' ]) ] ].
					stream space ].
			nameExtent := self extentForName: aGolapVertex name.
			fillColor
				ifNotNil: [ | rect |
					rect := aPoint
						extent:
							(nameExtent x max: (self font widthOfString: deltaString))
								@ (nameExtent y + self font height).
					aCanvas fillRectangle: rect color: Color white.
					aCanvas frameRectangle: rect width: 1 color: Color black.
					box := rect ].
			(self nameIntoLines: aGolapVertex name)
				doWithIndex: [ :line :y | 
					aCanvas
						drawString: line
						at: aPoint x @ ((y - 1) * self font height + aPoint y)
						font: self font
						color: aColor ].
			aCanvas
				drawString: deltaString
				at: aPoint x @ (nameExtent y + aPoint y)
				font: self font
				color: aColor ].
	^ box
]

{ #category : #drawing }
GolapOverviewRenderer >> drawVerticesOn: aCanvas [
	self
		modelDo: [ :model | 
			| scale freqScale labelOffset extent numLabels labelVertices |
			scale := self scale.
			freqScale := 30.0
				/
					((self vertices
						collect: [ :v | (v frequency abs + 0.1) log - 1.0 log ])
						ifEmpty: [ 1 ]
						ifNotEmpty: #max).
			labelOffset := 15 @ (self font height * -0.5).
			extent := self globalImageExtent.
			numLabels := (50.0 ** golap numLabels) truncated.
			labelVertices := SortedCollection
				sortBlock: [ :more :less | less value <= more value ].
			reallyVisibleVertices
				do: [ :vertex | 
					| p |
					(self colorForVertex: vertex)
						ifNotNil: [ :c | 
							p := vertex asPoint * scale + viewOffset.
							((p x between: 0.0 and: extent x)
								and: [ p y between: 0.0 and: extent y ])
								ifTrue: [ | r |
									r := ((vertex frequency abs + 0.1) log - 1.0 log) * freqScale
										max: 10.
									aCanvas
										fillOval: (Rectangle center: p extent: r asPoint)
										color: c.
									golap
										markersAndVerticesDo: [ :color :vs | 
											color
												ifNotNil: [ (vs includes: vertex)
														ifTrue: [ r := r + 8.
															aCanvas
																frameOval: (Rectangle center: p extent: r asPoint)
																width: 4
																color: color ] ] ].
									labelVertices add: vertex -> (model valueAtVertex: vertex).
									labelVertices size > numLabels
										ifTrue: [ labelVertices removeLast ] ] ] ].
			labelVertices
				do: [ :assoc | 
					| vertex |
					vertex := assoc key.
					(self colorForVertex: vertex)
						ifNotNil: [ :c | 
							| p lp |
							p := vertex asPoint * scale + viewOffset.
							lp := p
								+
									(((golap visibleEdges
										collect: [ :edge | 
											(edge peerOf: vertex)
												ifNil: [ 0 ]
												ifNotNil: [ :peer | peer x - vertex x ] ])
										ifEmpty: [ 0 ]
										ifNotEmpty: #sum) <= 0.0
										ifTrue: [ labelOffset ]
										ifFalse: [ (((self extentForName: vertex name) x + labelOffset x) * -1)
												@ labelOffset y ]).
							self
								drawVertexLabelFor: vertex
								at: lp
								color: c
								fillColor: nil
								on: aCanvas ] ] ]
]

{ #category : #drawing }
GolapOverviewRenderer >> globalImage [

	| form |
	form := (inactiveImage notNil and: [ 
		         inactiveImage extent = self globalImageExtent ])
		        ifTrue: [ inactiveImage ]
		        ifFalse: [ Form extent: self globalImageExtent depth: 32 ].
	self updateVisibleEdgeThresholds.
	self modelDo: [ :model | 
		form getCanvas in: [ :canvas | 
			canvas fillColor: Color white.
			self drawVerticesOn: canvas.
			self drawEdgesOn: canvas.
			self drawSelectionsOn: canvas.
			self drawPinsOn: canvas ] ].
	inactiveImage := activeImage.
	^ activeImage := form
]

{ #category : #drawing }
GolapOverviewRenderer >> globalMap [

	| form canvas vs min max |
	form := (inactiveMap notNil and: [ 
		         inactiveMap extent = self globalMapExtent ])
		        ifTrue: [ inactiveMap ]
		        ifFalse: [ Form extent: self globalMapExtent depth: 32 ].
	canvas := form getCanvas.
	canvas fillColor: (Color gray: 0.95).
	canvas
		frameAndFillRectangle:
			(viewOffset negated / self scale - mapOffset * mapScale corner:
				 ((golap globalImagePane adapter ifNotNil: #widget)
					  ifNil: [ 300 @ 300 ]
					  ifNotNil: [ :w | w extent ]) - viewOffset / self scale
				 - mapOffset * mapScale)
		fillColor: Color white
		borderWidth: 1
		borderColor: Color red.
	(vs := self vertices reject: #isNil) ifEmpty: [ ^ form ].
	min := (vs collect: [ :v | v asPoint ] thenSelect: #notNil) min.
	max := (vs collect: [ :v | v asPoint ] thenSelect: #notNil) max.
	mapScale := 200.0 asPoint / (max - min max: 1.0e-8 asPoint).
	mapOffset := min - (50.0 / mapScale).
	golap visibleEdges do: [ :edge | 
		canvas
			line: edge vertex1 asPoint - mapOffset * mapScale
			to: edge vertex2 asPoint - mapOffset * mapScale
			color: Color black ].
	inactiveMap := activeMap.
	^ activeMap := form
]

{ #category : #initialization }
GolapOverviewRenderer >> initialize [
	super initialize.
	mapScale := 1.0 @ 1.0.
	mapOffset := 0.0 @ 0.0.
	viewScale := 1.0.
	viewOffset := 0.0 @ 0.0
]

{ #category : #'view manipulation' }
GolapOverviewRenderer >> layout [ 
	^ self layouter layout
]

{ #category : #accessing }
GolapOverviewRenderer >> layouter [
	^ layouter ifNil: [ layouter := GolapLayouter on: golap model ]
]

{ #category : #accessing }
GolapOverviewRenderer >> maxScale [
	^ 50.0
]

{ #category : #accessing }
GolapOverviewRenderer >> minScale [
	^ 0.9
]

{ #category : #'view manipulation' }
GolapOverviewRenderer >> moveImageOffset: aPoint [

	viewOffset := aPoint + viewOffset.
	self snapshotLazy 
]

{ #category : #'view manipulation' }
GolapOverviewRenderer >> moveMapOffset: aPoint [

	activeImage ifNil: [ ^ self ].
	activeMap ifNil: [ ^ self ].
	"viewOffset := aPoint x / activeImage extent x asFloat
	              * activeMap extent x asFloat + viewOffset x
	              @
		              (aPoint y / activeImage extent y asFloat
		               * activeMap extent y asFloat + viewOffset y)."
	viewOffset := aPoint * 2.0 + viewOffset.
	self snapshotLazy
]

{ #category : #accessing }
GolapOverviewRenderer >> overridesYWithFrequency: aBoolean [
	self layouter overridesYWithFrequency: aBoolean.
	self snapshot
]

{ #category : #'view manipulation' }
GolapOverviewRenderer >> resetZoom [
	viewScale := 1.0.
	viewOffset := 0 @ 0.
	self snapshot
]

{ #category : #snapshot }
GolapOverviewRenderer >> restore: aStream [

	| x y |
	x := nil.
	y := nil.
	(NeoJSONReader on: aStream) next
		at: 'overrides-y-with-frequency'
		ifPresent: [ :bool | 
			golap overridesYWithFrequencyCheckbox state: bool ];
		at: 'offset-x' ifPresent: [ :float | x := float ];
		at: 'offset-y' ifPresent: [ :float | y := float ];
		at: 'scale' ifPresent: [ :float | viewScale := float ].
	(x notNil and: [ y notNil ]) ifTrue: [ viewOffset := x @ y ]
]

{ #category : #accessing }
GolapOverviewRenderer >> scale [
	| extent |
	extent := self globalImageExtent.
	extent isZero
		ifTrue: [ ^ 1 ].
	^ (extent x min: extent y) / self layouter divisions asFloat
		* viewScale
]

{ #category : #private }
GolapOverviewRenderer >> simpleStringFor: aNumber [
	aNumber isNil
		ifTrue: [ ^ '' ].
	aNumber isNumber
		ifFalse: [ ^ aNumber printString ].
	aNumber isInteger
		ifTrue: [ ^ aNumber printString ].
	aNumber isInfinite
		ifTrue: [ aNumber > 0.0
				ifTrue: [ ^ '+∞' ]
				ifFalse: [ ^ '-∞' ] ].
	aNumber isNaN
		ifTrue: [ ^ 'NaN' ].
	^ aNumber printShowingDecimalPlaces: 4
]

{ #category : #snapshot }
GolapOverviewRenderer >> snapshotInto: aStream [

	(NeoJSONWriter on: aStream) nextPut: { 
			('overrides-y-with-frequency' -> layouter overridesYWithFrequency).
			('offset-x' -> (viewOffset ifNotNil: #x)).
			('offset-y' -> (viewOffset ifNotNil: #y)).
			('scale' -> viewScale) } asOrderedDictionary
]

{ #category : #snapshot }
GolapOverviewRenderer >> snapshotStreamDo: aBlock [

	golap snapshotOverviewRenderer: aBlock
]

{ #category : #drawing }
GolapOverviewRenderer >> svg [
	| svg |
	svg := XenqSVG extent: self globalImageExtent.
	self updateVisibleEdgeThresholds.
	self
		modelDo: [ :model | 
			svg getCanvas
				in: [ :canvas | 
					canvas fillColor: Color white.
					self drawVerticesOn: canvas.
					self drawEdgesOn: canvas.
					self drawSelectionsOn: canvas.
					self drawPinsOn: canvas ] ].
	^ svg
]

{ #category : #'view manipulation' }
GolapOverviewRenderer >> validateViewOffset: aPoint [
	| min max d |
	self vertices ifEmpty: [ ^ aPoint ].
	min := (self vertices collect: [ :v | v asPoint ] thenSelect: #notNil)
		min.
	max := (self vertices collect: [ :v | v asPoint ] thenSelect: #notNil)
		max.
	d := max - min.
	mapScale := 250.0 asPoint / ((d x max: 1.0e-8) @ (d y max: 1.0e-8)).
	mapOffset := min - (50.0 / mapScale).
	^ aPoint
		min: self globalImageExtent - ((50.0 / mapScale + mapOffset) * self scale)
		max: (250.0 / mapScale + mapOffset) * self scale negated
]

{ #category : #accessing }
GolapOverviewRenderer >> vertexAtPoint: aPoint [

	| scale |
	scale := self scale.
	labelBoxes ifNotNil: [ 
		labelBoxes do: [ :assoc | 
			(assoc key containsPoint: aPoint) ifTrue: [ ^ assoc value ] ] ].
	^ self vertices
		  detect: [ :vertex | 
			  (vertex asPoint * scale + viewOffset distanceTo: aPoint) < 8 ]
		  ifNone: [ nil ]
]

{ #category : #'view manipulation' }
GolapOverviewRenderer >> zoom: aNumber [
	| handPosition widget scale halfExtent center |
	handPosition := self currentHand position.
	widget := ((golap globalMapPane adapter widget bounds
		containsPoint: handPosition)
		ifTrue: [ golap globalMapPane ]
		ifFalse: [ golap globalImagePane ]) adapter widget.
	halfExtent := self currentHand position - widget position.
	scale := self globalImageExtent / self layouter divisions asFloat
		* viewScale.
	center := (halfExtent - viewOffset) / scale.
	viewScale := viewScale * aNumber
		min: self maxScale
		max: self minScale.
	scale := self globalImageExtent / self layouter divisions asFloat
		* viewScale.
	viewOffset := halfExtent - (center * scale).
	self snapshotLazy 
]

{ #category : #'view manipulation' }
GolapOverviewRenderer >> zoomCenter: aNumber [

	| handPosition widget scale halfExtent center |
	widget := golap globalImagePane adapter widget.
	handPosition := widget center.
	halfExtent := widget center - widget position.
	scale := self globalImageExtent / self layouter divisions asFloat
	         * viewScale.
	center := halfExtent - viewOffset / scale.
	viewScale := viewScale * aNumber
		             min: self maxScale
		             max: self minScale.
	scale := self globalImageExtent / self layouter divisions asFloat
	         * viewScale.
	viewOffset := halfExtent - (center * scale).
	self snapshotLazy 
]
