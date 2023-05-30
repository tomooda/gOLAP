Class {
	#name : #GolapElaborationRenderer,
	#superclass : #GolapRenderer,
	#instVars : [
		'imageScale',
		'mapScale',
		'roots',
		'associates',
		'imageOffset',
		'maxLabelWidth'
	],
	#category : #'Golap-UI-Graph'
}

{ #category : #drawing }
GolapElaborationRenderer >> associateX [

	^ self globalImageExtent x - self maxLabelWidth - 10
]

{ #category : #drawing }
GolapElaborationRenderer >> associateX: extent [

	^ extent x - self maxLabelWidth - 10
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

	| height barWidth totalBarHeight margin frameWidth labelString scale boxTop boxRight form canvas |
	height := 64.
	barWidth := self barWidth.
	totalBarHeight := 15.
	margin := 0.
	frameWidth := 1.
	labelString := aGolapVertex name.
	scale := (barWidth - 2) asFloat
	         / (associates first totalScore asFloat max: 0.1).
	boxTop := height // 2 + frameWidth + margin - 5.
	boxRight := barWidth.
	form := Form
		        extent: (aGolapVertex photoimage
				         ifNil: [ 
				         (self font widthOfString: labelString) + (frameWidth * 2) ]
				         ifNotNil: [ :image | 
					         image width + ((golap includesSelection: aGolapVertex)
						          ifTrue: [ 
						          (self font widthOfString: labelString)
						          + (frameWidth * 2) ]
						          ifFalse: [ 0 ]) ]) + margin + barWidth @ height
		        depth: 32.
	canvas := form getCanvas.
	canvas fillColor: Color transparent.
	canvas
		fillRectangle: (barWidth @ 0 corner: form extent)
		color: Color white.
	aGolapVertex verticesAndScoresDo: [ :root :score | 
		| width rect borderColor fillColor |
		width := score * scale.
		rect := boxRight - width @ boxTop extent: width @ 10.
		aGolapVertex addRectangle: rect with: root.
		(golap includesSelection: root)
			ifTrue: [ 
				fillColor := Color lightGray.
				borderColor := Color black ]
			ifFalse: [ 
				fillColor := Color white.
				borderColor := Color gray ].
		canvas
			frameAndFillRectangle: rect
			fillColor: fillColor
			borderWidth: 1
			borderColor: borderColor.
		boxRight := boxRight - width ].
	aGolapVertex photoimage
		ifNotNil: [ :image | 
			canvas paintImage: image at: barWidth + margin @ 0.
			(golap includesSelection: aGolapVertex) ifTrue: [ 
				canvas
					drawString: labelString
					at: barWidth + margin + frameWidth + image width
						@ (height - self font height // 2)
					font: self font
					color: Color black ] ]
		ifNil: [ 
			canvas
				drawString: labelString
				at:
				barWidth + margin + frameWidth @ (height - self font height // 2)
				font: self font
				color: Color black ].
	canvas flush.
	^ form
]

{ #category : #drawing }
GolapElaborationRenderer >> createNameLabel: aGolapVertex [

	^ aGolapVertex photoimage
		  ifNotNil: [ :image | 
			  (golap includesSelection: aGolapVertex)
				  ifTrue: [ 
					  | height margin frameWidth labelString form |
					  height := 64.
					  margin := 2.
					  frameWidth := 1.
					  labelString := aGolapVertex name.
					  form := Form
						          extent:
							          image width + (self font widthOfString: labelString)
							          + (margin + frameWidth * 2) @ height
						          depth: 32.
					  form getCanvas
						  fillColor: Color white;
						  paintImage: image at: 0 @ 0;
						  drawString: labelString
						  at:
							  image width + margin + frameWidth
							  @ (height - self font height // 2)
						  font: self font
						  color: Color black;
						  flush.
					  form ]
				  ifFalse: [ image ] ]
		  ifNil: [ 
			  | height margin frameWidth labelString form |
			  height := 64.
			  margin := 2.
			  frameWidth := 1.
			  labelString := aGolapVertex name.
			  form := Form
				          extent:
					          (self font widthOfString: labelString)
					          + (margin + frameWidth * 2) @ height
				          depth: 32.
			  form getCanvas
				  fillColor: Color white;
				  drawString: labelString
				  at: margin + frameWidth @ (height - self font height // 2)
				  font: self font
				  color: Color black;
				  flush.
			  form ]
]

{ #category : #defaults }
GolapElaborationRenderer >> defaultImageScale [

	^ 80.0
]

{ #category : #drawing }
GolapElaborationRenderer >> drawEdgesOn: aCanvas extent: extent scale: scale offset: offset [

	| maxScore scoreScale rootIndices |
	associates ifEmpty: [ ^ self ].
	maxScore := 0.0.
	associates do: [ :vertex |
		vertex scoresDo: [ :score | maxScore := maxScore max: score ] ].
	scoreScale := maxScore <= 1.0e-8
		              ifTrue: [ 0.0 ]
		              ifFalse: [ 1.0 / maxScore * self edgeScale ].
	rootIndices := IdentityDictionary new: roots size.
	roots doWithIndex: [ :vertex :index |
		rootIndices at: vertex put: index ].
	associates doWithIndex: [ :vertex2 :index2 |
		| point2 image2 |
		image2 := vertex2 label.
		point2 := (self associateX: extent)
		          @ (index2 - offset * scale + (image2 height // 2)).
		vertex2 verticesAndScoresDo: [ :vertex1 :score |
			| image1 point1 selected |
			image1 := vertex1 label.
			point1 := (self rootX + image1 width) ceiling
			          @
			          ((rootIndices at: vertex1) - offset * scale
			           + (image1 height // 2)).
			selected := (golap includesSelection: vertex1) or: [
				            golap includesSelection: vertex2 ].
			aCanvas
				line: point1
				to: point2
				width: (selected
						 ifTrue: [ 2 ]
						 ifFalse: [ 1 ])
				color: (selected
						 ifTrue: [ Color black ]
						 ifFalse: [ Color black alpha: (score * scoreScale max: 0.1) ]).
			selected ifTrue: [
				(vertex1 edgeTo: vertex2 ifAbsent: [ nil ]) ifNotNil: [ :edge |
					| labelString labelForm |
					labelString := edge frequency printString.
					labelForm := Form
						             extent:
						             (self font widthOfString: labelString) + 6
						             @ (self font height + 4)
						             depth: 32.
					labelForm getCanvas
						fillColor: Color white;
						frameRectangle: (0 @ 0 extent: labelForm extent)
						width: 1
						color: Color black;
						drawString: labelString
						at: 3 @ 2
						font: self font
						color: Color black.
					aCanvas
						paintImage: labelForm
						at: point1 + point2 - labelForm extent // 2 ] ] ] ]
]

{ #category : #drawing }
GolapElaborationRenderer >> drawLabelForVertex: aGolapVertex on: aCanvas at: aPoint [

	| extent margin frameWidth labelString |
	extent := self labelExtentForVertex: aGolapVertex.
	margin := 2.
	frameWidth := 1.
	labelString := aGolapVertex name.
	aCanvas paintImage: aGolapVertex label at: aPoint
	"aCanvas
		fillRectangle: (aPoint extent: extent) color: Color white;
		drawString: labelString
		at:
			aPoint x + margin + frameWidth @ (aPoint y + margin + frameWidth)
		font: self font
		color: Color black;
		flush"
]

{ #category : #drawing }
GolapElaborationRenderer >> drawVerticesOn: aCanvas extent: extent scale: scale offset: offset [

	| font x point bounds |
	x := self rootX.
	font := TextStyle defaultFont.
	(1 max: offset floor) to:
		(roots size min: (extent y / scale + offset) ceiling + 1) do: [ 
		:index | 
		(roots at: index ifAbsent: [ nil ]) ifNotNil: [ :vertex | 
			| string |
			point := x @ (index asFloat - offset * scale) rounded.

			bounds := point extent:
				          (self labelExtentForVertex: vertex) - (1 @ 1).
			self drawLabelForVertex: vertex on: aCanvas at: point.
			string := golap simpleStringFor:
				          (golap model valueAtVertex: vertex).
			aCanvas
				drawString: string
				at: bounds origin x - (font widthOfString: string) - 5 @ point y
				font: font
				color: Color gray.
			(golap includesSelection: vertex) ifTrue: [ 
				aCanvas frameRectangle: bounds width: 2 color: Color black ].
			golap markersAndVerticesDo: [ :color :vs | 
				color ifNotNil: [ 
					(vs includes: vertex) ifTrue: [ 
						bounds := bounds expandBy: 4 @ 4.
						aCanvas frameRectangle: bounds width: 4 color: color ] ] ] ] ].
	x := self associateX: extent.
	(1 max: offset floor) to:
		(associates size min: (extent y / scale + offset) ceiling + 1) do: [ 
		:index | 
		(associates at: index ifAbsent: [ nil ]) ifNotNil: [ :vertex | 
			point := x @ (index asFloat - offset * scale) rounded.
			bounds := point x + self barWidth @ point y extent:
				          vertex label extent - (self barWidth @ 0).
			aCanvas paintImage: vertex label at: point.
			(golap includesSelection: vertex) ifTrue: [ 
				aCanvas frameRectangle: bounds width: 2 color: Color black ].
			golap markersAndVerticesDo: [ :color :vs | 
				color ifNotNil: [ 
					(vs includes: vertex) ifTrue: [ 
						bounds := bounds expandBy: 4 @ 4.
						aCanvas frameRectangle: bounds width: 4 color: color ] ] ] ] ]
]

{ #category : #drawing }
GolapElaborationRenderer >> fullBoundsWithMargin: aNumber [

	^ 0 @ 0 extent:
		  aNumber * 2.0 + 1200
		  @ ((roots size max: associates size) * imageScale
			   + TextStyle defaultFont height + (aNumber * 2.0))
]

{ #category : #drawing }
GolapElaborationRenderer >> fullImage [

	| bounds form canvas |
	bounds := self fullBoundsWithMargin: 50.0.
	form := Form extent: bounds extent depth: 32.
	self updateVisibleEdgeThresholds.
	canvas := form getCanvas.
	canvas fillColor: Color white.
	self
		drawEdgesOn: canvas
		extent: bounds extent
		scale: imageScale
		offset: 0.0;
		drawVerticesOn: canvas
		extent: bounds extent
		scale: imageScale
		offset: 0.0;
		yourself.
	canvas flush.
	^ form
]

{ #category : #drawing }
GolapElaborationRenderer >> globalImage [

	| form canvas |
	form := Form extent: self globalImageExtent depth: 32.
	self updateVisibleEdgeThresholds.
	canvas := form getCanvas.
	canvas fillColor: Color white.
	self
		drawEdgesOn: canvas
		extent: form extent
		scale: imageScale
		offset: imageOffset;
		drawVerticesOn: canvas
		extent: form extent
		scale: imageScale
		offset: imageOffset;
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
			(10 @ (imageOffset * mapScale) floor
				corner: (form width - 10) @ ((imageOffset + height) * mapScale) ceiling)
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
	imageOffset := 0.0
]

{ #category : #drawing }
GolapElaborationRenderer >> labelExtentForVertex: aGolapVertex [

	^ aGolapVertex label extent
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> layout [ 

]

{ #category : #private }
GolapElaborationRenderer >> maxLabelWidth [

	^ maxLabelWidth ifNil: [ 
		  | max |
		  max := 0.
		  associates do: [ :vertex | max := max max: vertex label width ].
		  maxLabelWidth := max ]
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> moveImageOffset: aPoint [

	imageOffset := (aPoint y negated / imageScale / 2.0 min: 3.0 max: -3.0)
	               + imageOffset
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> moveMapOffset: aPoint [

	imageOffset := (aPoint y negated / mapScale / 2.0 min: 3.0 max: -3.0)
	               + imageOffset
]

{ #category : #accessing }
GolapElaborationRenderer >> overridesYWithFrequency: aBoolean [
	
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> resetZoom [

	imageScale := self defaultImageScale.
	imageOffset := 0.0.
]

{ #category : #snapshot }
GolapElaborationRenderer >> restore: aStream [

	(NeoJSONReader on: aStream) next
		at: 'offset' ifPresent: [ :float | imageOffset := float ];
		at: 'scale' ifPresent: [ :float | imageScale := float ]
]

{ #category : #drawing }
GolapElaborationRenderer >> rootX [
	^ self baseX
]

{ #category : #snapshot }
GolapElaborationRenderer >> snapshotInto: aStream [

	(NeoJSONWriter on: aStream) nextPut: { 
			('offset' -> imageOffset).
			('scale' -> imageScale) } asOrderedDictionary
]

{ #category : #snapshot }
GolapElaborationRenderer >> snapshotStreamDo: aBlock [

	golap snapshotElaborationRenderer: aBlock
]

{ #category : #drawing }
GolapElaborationRenderer >> svg [

	| bounds svg canvas |
	bounds := self fullBoundsWithMargin: 50.
	svg := XenqSVG extent: bounds.
	self updateVisibleEdgeThresholds.
	canvas := svg getCanvas.
	canvas fillColor: Color white.
	self
		drawEdgesOn: canvas
		extent: bounds extent
		scale: imageScale
		offset: 50.0;
		drawVerticesOn: canvas
		extent: bounds extent
		scale: imageScale
		offset: 50.0;
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
		/ ((roots size max: associates size) + 1).
	maxLabelWidth := nil
]

{ #category : #accessing }
GolapElaborationRenderer >> vertexAtPoint: aPoint [

	| index |
	index := (aPoint y / imageScale + imageOffset) floor.
	self associateX <= aPoint x
		ifTrue: [ 
			| vertex |
			vertex := associates at: index ifAbsent: [ ^ nil ].
			vertex label ifNil: [ ^ nil ].
			^ ((aPoint y - (index - imageOffset * imageScale)
				    between: 0.0
				    and: (vertex photoimage ifNil: [ vertex label ]) height) and: [ 
				   aPoint x
					   between: self associateX
					   and: self associateX + self barWidth + vertex label width ])
				  ifTrue: [ vertex ]
				  ifFalse: [ nil ] ]
		ifFalse: [ 
			| vertex |
			vertex := roots at: index ifAbsent: [ ^ nil ].
			vertex label ifNil: [ ^ nil ].
			^ ((aPoint y - (index - imageOffset * imageScale)
				    between: 0.0
				    and: vertex label height) and: [ 
				   aPoint x
					   between: self rootX
					   and: self rootX + vertex label width ])
				  ifTrue: [ vertex ]
				  ifFalse: [ nil ] ]
]

{ #category : #enumerating }
GolapElaborationRenderer >> verticesDo: aBlock [

	roots do: aBlock.
	associates do: aBlock
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> zoom: aNumber [

	| handPosition oldCenterIndex newCenterIndex |
	handPosition := self currentHand position.
	oldCenterIndex := (golap globalMapPane adapter widget bounds 
		                   containsPoint: handPosition)
		                  ifTrue: [ 
		                  self globalImageExtent y / imageScale * 0.5
		                  + imageOffset ]
		                  ifFalse: [ 
			                  handPosition y
			                  - golap globalImagePane adapter widget bounds top
			                  / imageScale + 1 + imageOffset ].
	imageScale := imageScale * aNumber
		              min: self globalImageExtent y - 10
		              max: 10.0.
	newCenterIndex := (golap globalMapPane adapter widget bounds 
		                   containsPoint: handPosition)
		                  ifTrue: [ 
		                  self globalImageExtent y / imageScale * 0.5
		                  + imageOffset ]
		                  ifFalse: [ 
			                  handPosition y
			                  - golap globalImagePane adapter widget bounds top
			                  / imageScale + 1 + imageOffset ].
	imageOffset := oldCenterIndex - newCenterIndex + imageOffset
]

{ #category : #'view manipulation' }
GolapElaborationRenderer >> zoomCenter: aNumber [

	imageScale := imageScale * aNumber
		              min: self globalImageExtent y - 10
		              max: 10.0
]
