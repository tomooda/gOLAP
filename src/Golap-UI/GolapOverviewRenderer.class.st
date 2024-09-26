Class {
	#name : 'GolapOverviewRenderer',
	#superclass : 'GolapRenderer',
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
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'drawing' }
GolapOverviewRenderer >> drawEdgeLabelFor: aGolapEdge at: aPoint color: aColor on: aCanvas [

	| string w h rect |
	self modelDo: [ :model |
		string := String streamContents: [ :stream |
			          stream
				          space;
				          nextPutAll:
					          (self simpleStringFor: (model valueAtEdge: aGolapEdge)).
			          golap selectedFrontDimension ifNotNil: [ :frontModel |
				          golap selectedBaseDimension ifNotNil: [ :baseModel |
					          stream
						          nextPutAll: '=';
						          nextPutAll: ((frontModel
								            edgeBetween: aGolapEdge node1 id
								            and: aGolapEdge node2 id
								            ifAbsent: [
									            frontModel
										            hiddenEdgeBetween: aGolapEdge node1 id
										            and: aGolapEdge node2 id
										            ifAbsent: [ nil ] ])
								           ifNotNil: [ :e |
									           self simpleStringFor: (frontModel valueAtEdge: e) ]
								           ifNil: [ '0' ]);
						          nextPutAll: '-';
						          nextPutAll: ((baseModel
								            edgeBetween: aGolapEdge node1 id
								            and: aGolapEdge node2 id
								            ifAbsent: [
									            baseModel
										            hiddenEdgeBetween: aGolapEdge node1 id
										            and: aGolapEdge node2 id
										            ifAbsent: [ nil ] ])
								           ifNotNil: [ :e |
									           self simpleStringFor: (baseModel valueAtEdge: e) ]
								           ifNil: [ '0' ]);
						          space ] ] ].
		w := self font widthOfString: string.
		h := self font height.
		rect := Rectangle center: aPoint extent: w @ h.
		aCanvas fillRectangle: rect color: Color white.
		aCanvas frameRectangle: rect width: 1 color: Color black.
		aCanvas
			drawString: string
			at: aPoint - (w // 2 + 1 @ (h // 2 + 1))
			font: self font
			color: aColor ]
]

{ #category : 'drawing' }
GolapOverviewRenderer >> drawEdgesOn: aCanvas extent: extent scale: scale offset: offset [

	| maxValue lineScale |
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
				p1 := edge node1 asPoint * scale + offset.
				p2 := edge node2 asPoint * scale + offset.
				str := self simpleStringFor: v.
				(v notNil and: [ v isInfinite ]) ifTrue: [ 
					v := v > 0.0
						     ifTrue: [ maxValue * 2.0 ]
						     ifFalse: [ maxValue * -2.0 ] ].
				((golap includesSelection: edge node1) or: [ 
					 golap includesSelection: edge node2 ])
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
			((reallyVisibleNodes includes: edge node1) and: [ 
				 reallyVisibleNodes includes: edge node2 ]) ifTrue: [ 
				| p1 p2 |
				p1 := edge node1 asPoint * scale + offset.
				p2 := edge node2 asPoint * scale + offset.
				aCanvas
					line: p1
					to: p2
					width: (((golap includesSelection: edge node1) or: [ 
							  golap includesSelection: edge node2 ])
							 ifTrue: [ 4 ]
							 ifFalse: [ 2 ])
					color: color ] ] ].
	golap negativePolishColor ifNotNil: [ :color | 
		golap model negativePolishEdgesDo: [ :edge | 
			((reallyVisibleNodes includes: edge node1) and: [ 
				 reallyVisibleNodes includes: edge node2 ]) ifTrue: [ 
				| p1 p2 |
				p1 := edge node1 asPoint * scale + offset.
				p2 := edge node2 asPoint * scale + offset.
				aCanvas
					line: p1
					to: p2
					width: (((golap includesSelection: edge node1) or: [ 
							  golap includesSelection: edge node2 ])
							 ifTrue: [ 4 ]
							 ifFalse: [ 1 ])
					color: color ] ] ].
	golap selectedEdges do: [ :edge | 
		"edge data ifNotNil: [ "
			| c p1 p2 |
			c := Color black.
			p1 := edge node1 asPoint * scale + offset.
			p2 := edge node2 asPoint * scale + offset.
			aCanvas
				line: p1
				to: p2
				width: 2
				color: c.
			self
				drawEdgeLabelFor: edge
				at: p1 + p2 / 2.0 + (5 @ 5)
				color: c
				on: aCanvas ] "]"
]

{ #category : 'drawing' }
GolapOverviewRenderer >> drawNodeLabelFor: aGolapNode at: aPoint color: aColor fillColor: fillColor on: aCanvas [

	| box |
	box := nil.
	self modelDo: [ :model |
		| deltaString nameExtent |
		deltaString := String streamContents: [ :stream |
			               stream
				               space;
				               nextPutAll:
					               (self simpleStringFor:
							                (model valueAtNode: aGolapNode)).
			               golap selectedFrontDimension ifNotNil: [ :frontModel |
				               golap selectedBaseDimension ifNotNil: [ :baseModel |
					               stream
						               nextPutAll: '=';
						               nextPutAll:
							               ((frontModel
								                 nodeAt: aGolapNode id
								                 ifAbsent: [ nil ])
								                ifNotNil: [ :v |
									                self simpleStringFor:
											                (frontModel valueAtNode: v) ]
								                ifNil: [ '0' ]);
						               nextPutAll: '-';
						               nextPutAll:
							               ((baseModel
								                 nodeAt: aGolapNode id
								                 ifAbsent: [ nil ])
								                ifNotNil: [ :v |
									                self simpleStringFor:
											                (baseModel valueAtNode: v) ]
								                ifNil: [ '0' ]) ] ].
			               stream space ].
		nameExtent := self extentForName: aGolapNode name.
		fillColor ifNotNil: [
			| rect |
			rect := aPoint extent:
				        (nameExtent x max: (self font widthOfString: deltaString))
				        @ (nameExtent y + self font height).
			aCanvas fillRectangle: rect color: Color white.
			aCanvas frameRectangle: rect width: 1 color: Color black.
			box := rect ].
		(self nameIntoLines: aGolapNode name) doWithIndex: [ :line :y |
			aCanvas
				drawString: line
				at: aPoint x @ (y - 1 * self font height + aPoint y)
				font: self font
				color: aColor ].
		aCanvas
			drawString: deltaString
			at: aPoint x @ (nameExtent y + aPoint y)
			font: self font
			color: aColor ].
	^ box
]

{ #category : 'drawing' }
GolapOverviewRenderer >> drawNodesOn: aCanvas extent: extent scale: scale offset: offset numLabels: numLabels [

	self modelDo: [ :model |
		| freqScale labelOffset labelNodes markersAndNodes |
		freqScale := 30.0 / ((self nodes collect: [ :node |
			               ((model valueAtNode: node) abs + 0.1) log - 1.0 log ])
			              ifEmpty: [ 1 ]
			              ifNotEmpty: #max).
		labelOffset := 15 @ (self font height * -0.5).
		labelNodes := SortedCollection sortBlock: [ :more :less |
			              less value <= more value ].
		markersAndNodes := Array streamContents: [ :stream |
			                   golap markersAndNodesDo: [ :color :vs |
				                   color ifNotNil: [
					                   stream nextPut: color -> vs asIdentitySet ] ] ].
		reallyVisibleNodes do: [ :node |
			| p |
			(self colorForNode: node) ifNotNil: [ :c |
				p := node asPoint * scale + offset.
				((p x between: 0.0 and: extent x) and: [
					 p y between: 0.0 and: extent y ]) ifTrue: [
					| r |
					r := ((model valueAtNode: node) abs + 0.1) log - 1.0 log
					     * freqScale max: 10.
					golap selectedBaseDimension ifNotNil: [
						| pt pb |
						pt := p x + 32 + 6 @ (p y - r).
						pb := pt x @ (pt y + (r * 2)).
						(model valueAtNode: node) >= 0
							ifTrue: [
								aCanvas
									line: pt
									to: pb
									width: 3
									color: c;
									line: pt
									to: pt + (-5 @ 5)
									width: 3
									color: c;
									line: pt
									to: pt + (5 @ 5)
									width: 3
									color: c ]
							ifFalse: [
								aCanvas
									line: pt
									to: pb
									width: 3
									color: c;
									line: pb
									to: pb + (-5 @ -5)
									width: 3
									color: c;
									line: pb
									to: pb + (5 @ -5)
									width: 3
									color: c ] ].
					node photoimage
						ifNotNil: [ :photo |
							| w h |
							w := photo width.
							h := photo height.
							aCanvas drawImage: photo at: p x - (w // 2) @ (p y - (h // 2)).

							markersAndNodes do: [ :colorAndVs |
								(colorAndVs value includes: node) ifTrue: [
									w := w + 8.
									h := h + 8.
									aCanvas
										frameOval: (Rectangle center: p extent: w @ h)
										width: 4
										color: colorAndVs key ] ] ]
						ifNil: [
							aCanvas
								fillOval: (Rectangle center: p extent: r asPoint)
								color: c.
							markersAndNodes do: [ :colorAndVs |
								(colorAndVs value includes: node) ifTrue: [
									r := r + 8.
									aCanvas
										frameOval: (Rectangle center: p extent: r asPoint)
										width: 4
										color: colorAndVs key ] ].
							labelNodes add: node -> (model valueAtNode: node).
							(numLabels notNil and: [ labelNodes size > numLabels ])
								ifTrue: [ labelNodes removeLast ] ] ] ] ].
		labelNodes do: [ :assoc |
			| node |
			node := assoc key.
			node photoimage ifNil: [
				(self colorForNode: node) ifNotNil: [ :c |
					| p lp |
					p := node asPoint * scale + offset.
					lp := p + (((golap visibleEdges collect: [ :edge |
						         (edge peerOf: node)
							         ifNil: [ 0 ]
							         ifNotNil: [ :peer | peer x - node x ] ])
						        ifEmpty: [ 0 ]
						        ifNotEmpty: #sum) <= 0.0
						       ifTrue: [ labelOffset ]
						       ifFalse: [
							       (self extentForName: node name) x + labelOffset x * -1
							       @ labelOffset y ]).
					self
						drawNodeLabelFor: node
						at: lp
						color: c
						fillColor: nil
						on: aCanvas ] ] ] ]
]

{ #category : 'drawing' }
GolapOverviewRenderer >> drawPinsOn: aCanvas extent: extent scale: scale offset: offset [

	golap pinsDo: [ :node | 
		| p |
		p := node asPoint * scale + offset.
		aCanvas
			drawPolygon: { 
					p.
					(p + (7 @ -12)).
					(p + (-7 @ -12)) }
			fillStyle: Color red;
			fillOval: (p - (8 @ 21) extent: 16 @ 16) color: Color red;
			fillOval: (p - (3 @ 16) extent: 6 @ 6) color: Color white ]
]

{ #category : 'drawing' }
GolapOverviewRenderer >> drawSelectionsOn: aCanvas extent: extent scale: scale offset: offset [

	| labelOffset newLabelBoxes markersAndNodes |
	labelOffset := 15 @ (self font height * -0.5).
	newLabelBoxes := Array new writeStream.
	markersAndNodes := Array streamContents: [ :stream |
		                   golap markersAndNodesDo: [ :color :vs |
			                   color ifNotNil: [
				                   stream nextPut: color -> vs asIdentitySet ] ] ].
	golap selectedNodesDo: [ :node |
		(self colorForNode: node) ifNotNil: [ :c |
			| p lp |
			p := node asPoint * scale + offset.
			((p x between: 0.0 and: extent x) and: [
				 p y between: 0.0 and: extent y ]) ifTrue: [
				node photoimage ifNotNil: [ :photo |
					| w h |
					w := photo width.
					h := photo height.
					aCanvas
						paintImage: photo at: p x - (w // 2) @ (p y - (h // 2));
						frameRectangle: (Rectangle center: p extent: w @ h)
						width: 2
						color: c.
					markersAndNodes do: [ :colorAndNodes |
						(colorAndNodes value includes: node) ifTrue: [
							w := w + 8.
							h := h + 8.
							aCanvas
								frameOval: (Rectangle center: p extent: w @ h)
								width: 4
								color: colorAndNodes key ] ] ] ].
			lp := p + (((golap visibleEdges collect: [ :edge |
				         (edge peerOf: node)
					         ifNil: [ 0 ]
					         ifNotNil: [ :peer | peer x - node x ] ])
				        ifEmpty: [ 0.0 ]
				        ifNotEmpty: #sum) <= 0.0
				       ifTrue: [ labelOffset ]
				       ifFalse: [
					       (self extentForName: node name) x + labelOffset x * -1
					       @ labelOffset y ]).
			(self
				 drawNodeLabelFor: node
				 at: lp
				 color: c
				 fillColor: Color white
				 on: aCanvas) ifNotNil: [ :box |
				newLabelBoxes nextPut: box -> node ] ] ].
	labelBoxes := newLabelBoxes contents
]

{ #category : 'private' }
GolapOverviewRenderer >> fullBoundsWithMargin: aNumber [

	| scale vs |
	scale := self scale asPoint.
	vs := (reallyVisibleNodes collect: #asPoint thenSelect: #notNil) 
		      collect: [ :p | p * scale ].
	^ vs min - aNumber asPoint corner: vs max + aNumber asPoint
]

{ #category : 'drawing' }
GolapOverviewRenderer >> fullImage [

	| bounds extent form offset scale |
	self updateVisibleEdgeThresholds.
	bounds := self fullBoundsWithMargin: 200 @ 50.
	extent := bounds extent.
	offset := bounds origin negated.
	scale := self scale.

	form := Form extent: extent depth: 32.
	self modelDo: [ :model | 
		form getCanvas in: [ :canvas | 
			canvas fillColor: Color white.
			self
				drawNodesOn: canvas
				extent: extent
				scale: scale
				offset: offset
				numLabels: nil.
			self
				drawEdgesOn: canvas
				extent: extent
				scale: scale
				offset: offset.
			self
				drawSelectionsOn: canvas
				extent: extent
				scale: scale
				offset: offset.
			self
				drawPinsOn: canvas
				extent: extent
				scale: scale
				offset: offset ] ].
	^ form
]

{ #category : 'drawing' }
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
			self
				drawEdgesOn: canvas
				extent: form extent
				scale: self scale
				offset: viewOffset.
			self
				drawNodesOn: canvas
				extent: form extent
				scale: self scale
				offset: viewOffset
				numLabels: (50.0 ** golap numLabels) truncated.
			self
				drawSelectionsOn: canvas
				extent: form extent
				scale: self scale
				offset: viewOffset.
			self
				drawPinsOn: canvas
				extent: form extent
				scale: self scale
				offset: viewOffset ] ].
	inactiveImage := activeImage.
	^ activeImage := form
]

{ #category : 'drawing' }
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
	(vs := self nodes reject: #isNil) ifEmpty: [ ^ form ].
	min := (vs collect: [ :v | v asPoint ] thenSelect: #notNil) min.
	max := (vs collect: [ :v | v asPoint ] thenSelect: #notNil) max.
	mapScale := 200.0 asPoint / (max - min max: 1.0e-8 asPoint).
	mapOffset := min - (50.0 / mapScale).
	golap visibleEdges do: [ :edge | 
		canvas
			line: edge node1 asPoint - mapOffset * mapScale
			to: edge node2 asPoint - mapOffset * mapScale
			color: Color black ].
	inactiveMap := activeMap.
	^ activeMap := form
]

{ #category : 'initialization' }
GolapOverviewRenderer >> initialize [
	super initialize.
	mapScale := 1.0 @ 1.0.
	mapOffset := 0.0 @ 0.0.
	viewScale := 1.0.
	viewOffset := 0.0 @ 0.0
]

{ #category : 'view manipulation' }
GolapOverviewRenderer >> layout [ 
	^ self layouter layout
]

{ #category : 'accessing' }
GolapOverviewRenderer >> layouter [
	^ layouter ifNil: [ layouter := GolapLayouter on: golap model ]
]

{ #category : 'accessing' }
GolapOverviewRenderer >> maxScale [
	^ 50.0
]

{ #category : 'accessing' }
GolapOverviewRenderer >> minScale [
	^ 0.9
]

{ #category : 'view manipulation' }
GolapOverviewRenderer >> moveImageOffset: aPoint [

	| dx dy |
	dx := aPoint x min: 10 max: -10.
	dy := aPoint y min: 10 max: -10.
	viewOffset := dx @ dy + viewOffset
]

{ #category : 'view manipulation' }
GolapOverviewRenderer >> moveMapOffset: aPoint [

	| dx dy |
	activeImage ifNil: [ ^ self ].
	activeMap ifNil: [ ^ self ].
	dx := aPoint x * mapScale x min: 20 max: -20.
	dy := aPoint y * mapScale y min: 20 max: -20.
	viewOffset := dx @ dy + viewOffset
]

{ #category : 'accessing' }
GolapOverviewRenderer >> moveNode: aGolapNode to: aPoint [

	| p |
	p := self nodePointAtPoint: aPoint.
	aGolapNode
		x: p x;
		y: p y
]

{ #category : 'accessing' }
GolapOverviewRenderer >> nodeAtPoint: aPoint [

	| scale minD minV |
	scale := self scale.
	labelBoxes ifNotNil: [
		labelBoxes do: [ :assoc |
			(assoc key containsPoint: aPoint) ifTrue: [ ^ assoc value ] ] ].
	minD := Float infinity.
	minV := nil.
	reallyVisibleNodes ifNotNil: [
		reallyVisibleNodes do: [ :node |
			| p |
			p := node asPoint * scale + viewOffset.
			node photoimage
				ifNil: [
					| d |
					d := p distanceTo: aPoint.
					(d < 8 and: [ d < minD ]) ifTrue: [
						minD := d.
						minV := node ] ]
				ifNotNil: [ :image |
					| dp d |
					dp := p - aPoint.
					(dp x abs <= image width and: [
						 dp y abs <= image height and: [
							 (d := p distanceTo: aPoint) < minD ] ]) ifTrue: [
						minD := d.
						minV := node ] ] ] ].
	^ minV
]

{ #category : 'accessing' }
GolapOverviewRenderer >> nodePointAtPoint: aPoint [

	^ aPoint - viewOffset / self scale
]

{ #category : 'accessing' }
GolapOverviewRenderer >> overridesYWithFrequency: aBoolean [

	self layouter overridesYWithFrequency: aBoolean
]

{ #category : 'accessing' }
GolapOverviewRenderer >> overridesYWithFrequencyOrder: aBoolean [

	self layouter overridesYWithFrequencyOrder: aBoolean
]

{ #category : 'view manipulation' }
GolapOverviewRenderer >> resetZoom [

	viewScale := 1.0.
	viewOffset := 0 @ 0
]

{ #category : 'snapshot' }
GolapOverviewRenderer >> restore: aStream [

	| x y |
	x := nil.
	y := nil.
	(NeoJSONReader on: aStream) next
		at: 'overrides-y-with-frequency'
		ifPresent: [ :bool |
			golap overridesYWithFrequencyCheckbox state: bool ];
		at: 'overrides-y-with-frequency-order'
		ifPresent: [ :bool |
			golap overridesYWithFrequencyOrderCheckbox state: bool ];
		at: 'offset-x' ifPresent: [ :float | x := float ];
		at: 'offset-y' ifPresent: [ :float | y := float ];
		at: 'scale' ifPresent: [ :float | viewScale := float ].
	(x notNil and: [ y notNil ]) ifTrue: [ viewOffset := x @ y ]
]

{ #category : 'accessing' }
GolapOverviewRenderer >> scale [
	| extent |
	extent := self globalImageExtent.
	extent isZero
		ifTrue: [ ^ 1 ].
	^ (extent x min: extent y) / self layouter divisions asFloat
		* viewScale
]

{ #category : 'private' }
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

{ #category : 'snapshot' }
GolapOverviewRenderer >> snapshotInto: aStream [

	(NeoJSONWriter on: aStream) nextPut: {
			('overrides-y-with-frequency' -> layouter overridesYWithFrequency).
			('overrides-y-with-frequency-order'
			 -> layouter overridesYWithFrequencyOrder).
			('offset-x' -> (viewOffset ifNotNil: #x)).
			('offset-y' -> (viewOffset ifNotNil: #y)).
			('scale' -> viewScale) } asOrderedDictionary
]

{ #category : 'snapshot' }
GolapOverviewRenderer >> snapshotStreamDo: aBlock [

	golap snapshotOverviewRenderer: aBlock
]

{ #category : 'drawing' }
GolapOverviewRenderer >> svg [

	| bounds extent svg offset scale |
	self updateVisibleEdgeThresholds.
	bounds := self fullBoundsWithMargin: 50.
	extent := bounds extent.
	offset := bounds origin negated.
	scale := self scale.

	svg := XenqSVG extent: extent.
	self modelDo: [ :model | 
		svg getCanvas in: [ :canvas | 
			canvas fillColor: Color white.
			self
				drawNodesOn: canvas
				extent: extent
				scale: scale
				offset: offset
				numLabels: nil.
			self
				drawEdgesOn: canvas
				extent: extent
				scale: scale
				offset: offset.
			self
				drawSelectionsOn: canvas
				extent: extent
				scale: scale
				offset: offset.
			self
				drawPinsOn: canvas
				extent: extent
				scale: scale
				offset: offset ] ].
	^ svg
]

{ #category : 'view manipulation' }
GolapOverviewRenderer >> validateViewOffset: aPoint [
	| min max d |
	self nodes ifEmpty: [ ^ aPoint ].
	min := (self nodes collect: [ :v | v asPoint ] thenSelect: #notNil)
		min.
	max := (self nodes collect: [ :v | v asPoint ] thenSelect: #notNil)
		max.
	d := max - min.
	mapScale := 250.0 asPoint / ((d x max: 1.0e-8) @ (d y max: 1.0e-8)).
	mapOffset := min - (50.0 / mapScale).
	^ aPoint
		min: self globalImageExtent - ((50.0 / mapScale + mapOffset) * self scale)
		max: (250.0 / mapScale + mapOffset) * self scale negated
]

{ #category : 'view manipulation' }
GolapOverviewRenderer >> zoom: aNumber [

	| handPosition widget scale halfExtent center |
	handPosition := self currentHand position.
	widget := ((golap globalMapPane adapter widget bounds containsPoint:
		            handPosition)
		           ifTrue: [ golap globalMapPane ]
		           ifFalse: [ golap globalImagePane ]) adapter widget.
	halfExtent := self currentHand position - widget position.
	scale := self globalImageExtent / self layouter divisions asFloat
	         * viewScale.
	center := halfExtent - viewOffset / scale.
	viewScale := viewScale * aNumber
		             min: self maxScale
		             max: self minScale.
	scale := self globalImageExtent / self layouter divisions asFloat
	         * viewScale.
	viewOffset := halfExtent - (center * scale)
]

{ #category : 'view manipulation' }
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
	viewOffset := halfExtent - (center * scale)
]
