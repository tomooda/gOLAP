Class {
	#name : #GolapElaborationRenderer,
	#superclass : #GolapRenderer,
	#instVars : [
		'offset',
		'imageScale',
		'mapScale',
		'roots',
		'associates'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #drawing }
GolapElaborationRenderer >> associateX [
	^ self globalImageExtent x * 0.4 + self baseX
]

{ #category : #drawing }
GolapElaborationRenderer >> barWidth [
	^ 300
]

{ #category : #drawing }
GolapElaborationRenderer >> baseX [
	^ 100.0
]

{ #category : #drawing }
GolapElaborationRenderer >> createAssociatedVertexLabel: aGolapVertex [
	| barWidth totalBarHeight margin frameWidth labelString scale boxTop boxRight form canvas |
	barWidth := self barWidth.
	totalBarHeight := 15.
	margin := 0.
	frameWidth := 1.
	labelString := aGolapVertex name.
	scale := (barWidth - 2) asFloat
		/ (associates first totalScore asFloat max: 0.1).
	boxTop := self font height // 2 + frameWidth + margin - 5.
	boxRight := barWidth.
	form := Form
		extent:
			((self font widthOfString: labelString) + ((margin + frameWidth) * 2)
				+ barWidth)
				@ (self font height + ((margin + frameWidth) * 2) max: totalBarHeight)
		depth: 32.
	canvas := form getCanvas.
	canvas fillColor: Color transparent.
	canvas
		fillRectangle: (barWidth @ 0 corner: form extent)
		color: Color white.
	aGolapVertex
		verticesAndScoresDo: [ :root :score | 
			| width rect borderColor fillColor |
			width := score * scale.
			rect := (boxRight - width) @ boxTop extent: width @ 10.
			aGolapVertex addRectangle: rect with: root.
			(golap includesSelection: root)
				ifTrue: [ fillColor := Color lightGray.
					borderColor := Color black ]
				ifFalse: [ fillColor := Color white.
					borderColor := Color gray ].
			canvas
				frameAndFillRectangle: rect
				fillColor: fillColor
				borderWidth: 1
				borderColor: borderColor.
			boxRight := boxRight - width ].
	canvas
		drawString: labelString
			at: (barWidth + margin + frameWidth) @ (margin + frameWidth)
			font: self font
			color: Color black;
		flush.
	^ form
]

{ #category : #drawing }
GolapElaborationRenderer >> createNameLabel: aGolapVertex [
	| margin frameWidth labelString form |
	margin := 2.
	frameWidth := 1.
	labelString := aGolapVertex name.
	form := Form
		extent:
			(self font widthOfString: labelString) @ self font height
				+ ((margin + frameWidth) * 2)
		depth: 32.
	form getCanvas
		fillColor: Color white;
		drawString: labelString
			at: (margin + frameWidth) @ (margin + frameWidth)
			font: self font
			color: Color black;
		flush.
	^ form
]

{ #category : #defaults }
GolapElaborationRenderer >> defaultImageScale [
	^ 50.0
]

{ #category : #drawing }
GolapElaborationRenderer >> drawEdgesOn: aCanvas [
	| maxScore scale rootIndices |
	associates ifEmpty: [ ^ self ].
	maxScore := 0.0.
	associates
		do:
			[ :vertex | vertex scoresDo: [ :score | maxScore := maxScore max: score ] ].
	scale := maxScore <= 1.0e-8
		ifTrue: [ 0.0 ]
		ifFalse: [ 1.0 / maxScore * self edgeScale ].
	rootIndices := IdentityDictionary new: roots size.
	roots
		doWithIndex: [ :vertex :index | rootIndices at: vertex put: index ].
	associates
		doWithIndex: [ :vertex2 :index2 | 
			vertex2
				verticesAndScoresDo: [ :vertex1 :score | 
					| point1 point2 selected |
					point1 := (self rootX + vertex1 label width) ceiling
						@
							(((rootIndices at: vertex1) - offset) * imageScale
								+ (vertex1 label height * 0.5)).
					point2 := self associateX
						@ ((index2 - offset) * imageScale + (vertex2 label height * 0.5)).
					selected := (golap includesSelection: vertex1)
						or: [ golap includesSelection: vertex2 ].
					aCanvas
						line: point1
						to: point2
						width:
							(selected
								ifTrue: [ 2 ]
								ifFalse: [ 1 ])
						color:
							(selected
								ifTrue: [ Color black ]
								ifFalse: [ Color black alpha: (score * scale max: 0.1) ]) ] ]
]

{ #category : #drawing }
GolapElaborationRenderer >> drawLabelForVertex: aGolapVertex on: aCanvas at: aPoint [
	| extent margin frameWidth labelString |
	extent := self labelExtentForVertex: aGolapVertex.
	margin := 2.
	frameWidth := 1.
	labelString := aGolapVertex name.
	aCanvas
		fillRectangle: (aPoint extent: extent) color: Color white;
		drawString: labelString
			at: (aPoint x + margin + frameWidth) @ (aPoint y + margin + frameWidth)
			font: self font
			color: Color black;
		flush
]

{ #category : #drawing }
GolapElaborationRenderer >> drawVerticesOn: aCanvas [
	| font form x point bounds |
	form := aCanvas form.
	x := self rootX.
	font := TextStyle defaultFont.
	(1 max: offset floor) to: (roots size min: (form height / imageScale + offset) ceiling + 1)
	do: [ :index | 
		(roots at: index ifAbsent: [ nil ])
			ifNotNil: [ :vertex | 
				| string |
				point := x @ ((index asFloat - offset) * imageScale) rounded.
				bounds := point
					extent: (self labelExtentForVertex: vertex) - (1 @ 1).
				string := golap simpleStringFor: (golap model valueAtVertex: vertex).
				aCanvas drawString: string at: (point x - (font widthOfString: string) - 5 )@point y font: font color: Color gray.
				self drawLabelForVertex: vertex on: aCanvas at: point.
				(golap includesSelection: vertex)
					ifTrue: [ aCanvas frameRectangle: bounds width: 2 color: Color black ].
				golap
					markersAndVerticesDo: [ :color :vs | 
						color
							ifNotNil: [ (vs includes: vertex)
									ifTrue: [ bounds := bounds expandBy: 4 @ 4.
										aCanvas frameRectangle: bounds width: 4 color: color ] ] ] ] ].
	x := self associateX.
	(1 max: offset floor) to: (associates size min: (form height / imageScale + offset) ceiling + 1)
	do: [ :index | 
		(associates at: index ifAbsent: [ nil ])
			ifNotNil: [ :vertex | 
				point := x @ ((index asFloat - offset) * imageScale) rounded.
				bounds := (point x + self barWidth @ point y)
					extent: (vertex label extent) - (self barWidth @ 0).
				aCanvas paintImage: vertex label at: point.
				(golap includesSelection: vertex)
					ifTrue: [ aCanvas frameRectangle: bounds width: 2 color: Color black ].
				golap
					markersAndVerticesDo: [ :color :vs | 
						color
							ifNotNil: [ (vs includes: vertex)
									ifTrue: [ bounds := bounds expandBy: 4 @ 4.
										aCanvas frameRectangle: bounds width: 4 color: color ] ] ] ] ]
]

{ #category : #drawing }
GolapElaborationRenderer >> globalImage [
	| form canvas |
	form := Form extent: self globalImageExtent depth: 32.
	self updateVisibleEdgeThresholds.
	canvas := form getCanvas.
	canvas fillColor: Color white.
	self
		drawEdgesOn: canvas;
		drawVerticesOn: canvas;
		yourself.
	canvas flush.
	^ form
]

{ #category : #drawing }
GolapElaborationRenderer >> globalImageAndMap [
	self updateRootsAndAssociates.
	^  super globalImageAndMap
]

{ #category : #drawing }
GolapElaborationRenderer >> globalMap [
	| form canvas height x |
	form := Form extent: self globalMapExtent depth: 32.
	canvas := form getCanvas.
	canvas fillColor: Color white.
	height := self globalImageExtent y asFloat / imageScale.
	canvas
		frameRectangle:
			(10 @ (offset * mapScale) floor
				corner: (form width - 10) @ ((offset + height) * mapScale) ceiling)
		color: Color red.
	x := 50.
	1 to: roots size do: [ :index | 
		canvas
			fillRectangle: (x @ (index * mapScale) rounded extent: 3 @ 3)
			color: Color black ].
	x := self globalMapExtent x // 2 + 50.
	1 to: associates size do: [ :index | 
		canvas
			fillRectangle: (x @ (index * mapScale) rounded extent: 3 @ 3)
			color: Color black ].
	^ form
]

{ #category : #accessing }
GolapElaborationRenderer >> golap: aGolap [
	super golap: aGolap.
	self updateRootsAndAssociates.
	self resetZoom
]

{ #category : #initialization }
GolapElaborationRenderer >> initialize [
	super initialize.
	mapScale := 1.0.
	imageScale := 1.0.
	offset := 0.0
]

{ #category : #drawing }
GolapElaborationRenderer >> labelExtentForVertex: aGolapVertex [
	| margin frameWidth labelString |
	margin := 2.
	frameWidth := 1.
	labelString := aGolapVertex name.
	^ (self font widthOfString: labelString) @ self font height
		+ ((margin + frameWidth) * 2) asPoint
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> layout [ 

]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> moveImageOffset: aPoint [
	offset := aPoint y negated / imageScale + offset.
	self snapshotLazy
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> moveMapOffset: aPoint [
	offset := aPoint y negated / mapScale + offset.
	self snapshotLazy
]

{ #category : #accessing }
GolapElaborationRenderer >> overridesYWithFrequency: aBoolean [
	
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> resetZoom [
	imageScale := self defaultImageScale.
	self snapshot
]

{ #category : #snapshot }
GolapElaborationRenderer >> restore: aStream [

	(NeoJSONReader on: aStream) next
		at: 'offset' ifPresent: [ :float | offset := float ];
		at: 'scale' ifPresent: [ :float | imageScale := float ]
]

{ #category : #drawing }
GolapElaborationRenderer >> rootX [
	^ self baseX
]

{ #category : #snapshot }
GolapElaborationRenderer >> snapshotInto: aStream [

	(NeoJSONWriter on: aStream) nextPut: { 
			('offset' -> offset).
			('scale' -> imageScale) } asOrderedDictionary
]

{ #category : #snapshot }
GolapElaborationRenderer >> snapshotStreamDo: aBlock [

	golap snapshotElaborationRenderer: aBlock
]

{ #category : #drawing }
GolapElaborationRenderer >> svg [
	| svg canvas |
	svg := XenqSVG extent: self globalImageExtent.
	self updateVisibleEdgeThresholds.
	canvas := svg getCanvas.
	canvas fillColor: Color white.
	self
		drawEdgesOn: canvas;
		drawVerticesOn: canvas;
		yourself.
	canvas flush.
	^ svg
]

{ #category : #private }
GolapElaborationRenderer >> updateRootsAndAssociates [
	| oldRoots rootSet associateSet |
	oldRoots := roots.
	roots := golap model
		ifNotNil: [ :model | 
			golap markedVertices
				asSortedCollection:
					[ :more :less | (model valueAtVertex: less) <= (model valueAtVertex: more) ] ]
		ifNil: [ Array new ].
	rootSet := roots asIdentitySet.
	associateSet := IdentitySet new: roots size * 2.
	self
		modelDo: [ :model | 
			model
				verticesDo: [ :vertex | 
					vertex
						resetScores;
						label: nil ].
			roots
				do: [ :vertex | 
					vertex
						edgesAndVerticesDo: [ :edge :peer | 
							(rootSet includes: peer)
								ifFalse: [ associateSet add: peer.
									peer addScore: (model valueAtEdge: edge) vertex: vertex ] ] ] ].
	associates := associateSet
		asSortedCollection: [ :more :less | less totalScore <= more totalScore ].
	roots do: [ :vertex | vertex label: (self createNameLabel: vertex) ].
	associates
		do: [ :vertex | vertex label: (self createAssociatedVertexLabel: vertex) ].
	mapScale := self globalMapExtent y
		/ ((roots size max: associates size) + 1)
]

{ #category : #accessing }
GolapElaborationRenderer >> vertexAtPoint: aPoint [
	| index |
	index := (aPoint y / imageScale + offset) floor.
	self associateX <= aPoint x
		ifTrue: [ | vertex |
			vertex := associates at: index ifAbsent: [ ^ nil ].
			vertex label ifNil: [ ^ nil ].
			^ ((aPoint y - ((index - offset) * imageScale)
				between: 0.0
				and: vertex label height)
				and: [ aPoint x
						between: self associateX
						and: self associateX + self barWidth + vertex label width ])
				ifTrue: [ vertex ]
				ifFalse: [ nil ] ]
		ifFalse: [ | vertex |
			vertex := roots at: index ifAbsent: [ ^ nil ].
			vertex label ifNil: [ ^ nil ].
			^ ((aPoint y - ((index - offset) * imageScale)
				between: 0.0
				and: vertex label height)
				and: [ aPoint x between: self rootX and: self rootX + vertex label width ])
				ifTrue: [ vertex ]
				ifFalse: [ nil ] ]
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> zoom: aNumber [
	| handPosition oldCenterIndex newCenterIndex |
	handPosition := self currentHand position.
	oldCenterIndex := (golap globalMapPane adapter widget bounds
		containsPoint: handPosition)
		ifTrue: [ self globalImageExtent y / imageScale * 0.5 + offset ]
		ifFalse: [ (handPosition y - golap globalImagePane adapter widget bounds top)
				/ imageScale + 1 + offset ].
	imageScale := imageScale * aNumber
		min: self globalImageExtent y - 10
		max: 10.0.
	newCenterIndex := (golap globalMapPane adapter widget bounds
		containsPoint: handPosition)
		ifTrue: [ self globalImageExtent y / imageScale * 0.5 + offset ]
		ifFalse: [ (handPosition y - golap globalImagePane adapter widget bounds top)
				/ imageScale + 1 + offset ].
	offset := oldCenterIndex - newCenterIndex + offset.
	self snapshotLazy
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> zoomCenter: aNumber [

	imageScale := imageScale * aNumber
		              min: self globalImageExtent y - 10
		              max: 10.0.
	self snapshotLazy
]
