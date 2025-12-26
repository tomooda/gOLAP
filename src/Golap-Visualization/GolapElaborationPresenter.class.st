Class {
	#name : 'GolapElaborationPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'gapSlider',
		'roassal',
		'scale',
		'offset',
		'golap',
		'rootNodes',
		'associateNodes',
		'nodes',
		'positions',
		'barScale',
		'nodeInteraction',
		'edgeInteraction',
		'associateBaseX'
	],
	#category : 'Golap-Visualization-Elaboration',
	#package : 'Golap-Visualization',
	#tag : 'Elaboration'
}

{ #category : 'updating' }
GolapElaborationPresenter >> activateOnNotebookPage [
]

{ #category : 'accessing' }
GolapElaborationPresenter >> camera [

	^ self canvas camera
]

{ #category : 'accessing' }
GolapElaborationPresenter >> cameraScale [

	^ self camera scale
]

{ #category : 'accessing' }
GolapElaborationPresenter >> cameraScale: aNumber [

	self camera scale: aNumber
]

{ #category : 'accessing' }
GolapElaborationPresenter >> canvas [

	^ roassal canvas
]

{ #category : 'layout' }
GolapElaborationPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: '左右ギャップ' expand: false;
				   add: gapSlider width: 200;
				   yourself)
		  expand: false;
		  add: roassal expand: true;
		  yourself
]

{ #category : 'updating' }
GolapElaborationPresenter >> gapSliderChanged [

	self updateAssociateNodePositions.
	self canvas signalUpdate
]

{ #category : 'accessing' }
GolapElaborationPresenter >> golap: aGolap [
	golap := aGolap.
	self golapChanged
]

{ #category : 'updating' }
GolapElaborationPresenter >> golapChanged [

	
]

{ #category : 'enumerating' }
GolapElaborationPresenter >> golapDo: aBlock [

	^ golap ifNotNil: aBlock
]

{ #category : 'enumerating' }
GolapElaborationPresenter >> golapModelDo: aBlock [

	^ golap ifNotNil: [ golap model ifNotNil: aBlock ]
]

{ #category : 'initialization' }
GolapElaborationPresenter >> initialize [

	super initialize.
	scale := 1.0 @ 1.0.
	offset := 0.0 @ 0.0.
	barScale := 1.0.
	nodeInteraction := GolapElaborationNodeInteraction new
		                   presenter: self;
		                   yourself.
	edgeInteraction := GolapElaborationEdgeInteraction new
		                   presenter: self;
		                   yourself.
	rootNodes := Array new.
	associateNodes := Array new
]

{ #category : 'initialization' }
GolapElaborationPresenter >> initializePresenters [

	super initializePresenters.
	gapSlider := self newSlider
		             min: 0;
		             max: 1000;
		             quantum: 100;
		             value: 500;
		             whenValueChangedDo: [ self gapSliderChanged ];
		             yourself.
	roassal := self newRoassal
		           canvas: RSCanvas new @ self newCanvasController;
		           yourself
]

{ #category : 'operations' }
GolapElaborationPresenter >> move: aPoint [

	self offset: aPoint / scale + offset.
	self updateNodeShapePositions.
	self canvas signalUpdate
]

{ #category : 'instance creation' }
GolapElaborationPresenter >> newBarForAssociateNode: aGolapNode [

	self golapModelDo: [ :golapModel |
			| shapes baseX |
			shapes := RSGroup new.
			baseX := 0.0.
			rootNodes do: [ :rootNode |
					(aGolapNode edgeTo: rootNode ifAbsent: [ nil ]) ifNotNil: [ :edge |
							(golapModel valueAtEdge: edge) ifNotNil: [ :v |
									| box |
									box := RSBox new
										       model: rootNode;
										       origin: baseX @ 0.0
										       corner: (baseX := v * barScale + baseX) @ 10;
										       color: ((golap includesSelection: rootNode)
												        ifTrue: [ Color gray ]
												        ifFalse: [ Color white ]);
										       borderColor: Color black;
										       borderWidth: 1;
										       yourself.
									box @ nodeInteraction.
									shapes add: box ] ] ].
			shapes := shapes asShape.
			^ shapes ].
	^ nil
]

{ #category : 'initialization' }
GolapElaborationPresenter >> newCanvasController [

	^ GolapElaborationController new
		  presenter: self;
		  yourself
]

{ #category : 'instance creation' }
GolapElaborationPresenter >> newLabelForEdge: aGolapEdge [

	^ self golapModelDo: [ :golapModel |
			  (golap colorForEdge: aGolapEdge) ifNotNil: [ :color |
					  ((golap includesSelection: aGolapEdge node1) or: [
						   golap includesSelection: aGolapEdge node2 ])
						  ifTrue: [
								  | string label |
								  string := String streamContents: [ :stream |
										            stream nextPutAll:
											            (golap simpleStringFor:
												             (golapModel valueAtEdge: aGolapEdge)).
										            golap selectedFrontDimension ifNotNil: [
												            :frontModel |
												            golap selectedBaseDimension ifNotNil: [
														            :baseModel |
														            stream
															            nextPutAll: '=';
															            nextPutAll: ((frontModel
																	              edgeBetween: aGolapEdge node1 id
																	              and: aGolapEdge node2 id
																	              ifAbsent: [
																			              frontModel
																				              hiddenEdgeBetween:
																					              aGolapEdge node1 id
																				              and: aGolapEdge node2 id
																				              ifAbsent: [ nil ] ])
																	             ifNotNil: [ :e |
																		             golap simpleStringFor:
																				             (frontModel valueAtEdge: e) ]
																	             ifNil: [ '0' ]);
															            nextPutAll: '-';
															            nextPutAll: ((baseModel
																	              edgeBetween: aGolapEdge node1 id
																	              and: aGolapEdge node2 id
																	              ifAbsent: [
																			              baseModel
																				              hiddenEdgeBetween:
																					              aGolapEdge node1 id
																				              and: aGolapEdge node2 id
																				              ifAbsent: [ nil ] ])
																	             ifNotNil: [ :e |
																		             golap simpleStringFor:
																				             (baseModel valueAtEdge: e) ]
																	             ifNil: [ '0' ]);
															            space ] ] ].
								  label := RSLabel new
									           text: string;
									           color: color.
								  {
									  (RSBox new
										   extent: label extent + 4 asPoint;
										   color: Color white;
										   borderColor: color;
										   borderWidth: 1;
										   yourself).
									  label } asShape ]
						  ifFalse: [ nil ] ] ]
]

{ #category : 'instance creation' }
GolapElaborationPresenter >> newLabelForNode: aGolapNode [

	^ self golapModelDo: [ :model |
			  (golap colorForNode: aGolapNode) ifNotNil: [ :color |
					  | label |
					  label := self
						           newLabelFromLines:
							           ((aGolapNode name substrings:
								             golap class nameEndOfLineDelimiter) copyWith:
								            (String streamContents: [ :stream |
										             stream nextPutAll:
											             (golap simpleStringFor:
												              (model valueAtNode: aGolapNode)).
										             golap selectedFrontDimension ifNotNil: [
												             :frontModel |
												             golap selectedBaseDimension ifNotNil: [
														             :baseModel |
														             stream
															             nextPutAll: '=';
															             nextPutAll:
																             ((frontModel
																	               nodeAt: aGolapNode id
																	               ifAbsent: [ nil ])
																	              ifNotNil: [ :v |
																		              golap simpleStringFor:
																				              (frontModel valueAtNode: v) ]
																	              ifNil: [ '0' ]);
															             nextPutAll: '-';
															             nextPutAll:
																             ((baseModel
																	               nodeAt: aGolapNode id
																	               ifAbsent: [ nil ])
																	              ifNotNil: [ :v |
																		              golap simpleStringFor:
																				              (baseModel valueAtNode: v) ]
																	              ifNil: [ '0' ]) ] ] ]))
						           color: color.
					  aGolapNode photoimage ifNotNil: [ :form |
							  | bitmap |
							  bitmap := RSBitmap new form: form.
							  label := {
								           (bitmap translateTo: bitmap extent * 0.5).
								           (label translateTo:
									            label extent * 0.5 + (0 @ bitmap extent y)) }
								           asShape ].
					  (golap includesSelection: aGolapNode) ifTrue: [
							  label := {
								           (RSBox new
									            extent: label extent + 4 asPoint;
									            position: label position;
									            color: Color white;
									            borderColor: color;
									            borderWidth: 2;
									            yourself).
								           label } asShape ].
					  label ] ]
]

{ #category : 'instance creation' }
GolapElaborationPresenter >> newLabelFromLines: anArrayOfString color: aColor [

	| y |
	y := 0.
	^ (anArrayOfString collect: [ :string |
			   | label |
			   label := RSLabel new
				            text: string;
				            color: aColor;
				            yourself.
			   label position:
				   label extent x * 0.5 @ (label extent y * 0.5 + y).
			   y := y + label extent y.
			   label ]) asShape
]

{ #category : 'instance creation' }
GolapElaborationPresenter >> newPinShape [

	^ {
		  (RSPolygon new
			   points: {
					   (-7 @ -12).
					   (7 @ -12).
					   (0 @ 0) };
			   color: Color red;
			   yourself).
		  (RSCircle new
			   extent: 16 @ 16;
			   position: 0 @ -16;
			   color: Color red;
			   yourself).
		  (RSCircle new
			   extent: 6 @ 6;
			   position: 0 @ -16;
			   color: Color white;
			   yourself) } asShape
]

{ #category : 'instance creation' }
GolapElaborationPresenter >> newShapeForAssociateNode: aGolapNode [

	self golapModelDo: [ :golapModel |
			| shapes markersAndNodes |
			shapes := RSGroup new.
			markersAndNodes := Array streamContents: [ :stream |
					                   golap markersAndNodesDo: [ :c :vs |
						                   c ifNotNil: [
							                   stream nextPut: c -> vs asIdentitySet ] ] ].
			(golap colorForNode: aGolapNode) ifNotNil: [ :color |
					| shape |
					shape := self newLabelForNode: aGolapNode.
					self canvas addNode: shape.
					nodes at: aGolapNode put: shape.
					shapes add: shape.
					markersAndNodes do: [ :colorAndVs |
							(colorAndVs value includes: aGolapNode) ifTrue: [
									shape := RSBox new
										         position: shape position;
										         extent: shape extent + 4 asPoint;
										         borderWidth: 4;
										         borderColor: colorAndVs key;
										         color: Color transparent;
										         yourself.
									shapes add: shape ] ].
					(golap includesPin: aGolapNode) ifTrue: [
						shapes add: self newPinShape ].
					shapes add:
						((self newBarForAssociateNode: aGolapNode) translateBy:
							 0 @ shape extent y) ].
			shapes := shapes asShapeFor: aGolapNode.
			^ shapes ].
	^ nil
]

{ #category : 'instance creation' }
GolapElaborationPresenter >> newShapeForEdge: aGolapEdge [

	self golapModelDo: [ :golapModel |
			(golap colorForEdge: aGolapEdge) ifNotNil: [ :color |
					| fromShape toShape line |
					fromShape := nil.
					toShape := nil.
					((rootNodes includes: aGolapEdge node1) and: [
						 associateNodes includes: aGolapEdge node2 ]) ifTrue: [
							fromShape := nodes at: aGolapEdge node1 ifAbsent: [ ^ nil ].
							toShape := nodes at: aGolapEdge node2 ifAbsent: [ ^ nil ] ].
					((rootNodes includes: aGolapEdge node2) and: [
						 associateNodes includes: aGolapEdge node1 ]) ifTrue: [
							fromShape := nodes at: aGolapEdge node2 ifAbsent: [ ^ nil ].
							toShape := nodes at: aGolapEdge node1 ifAbsent: [ ^ nil ] ].
					fromShape ifNil: [ ^ nil ].
					toShape ifNil: [ ^ nil ].
					line := RSLine new
						        model: aGolapEdge;
						        withHorizontalAttachPoint;
						        from: fromShape;
						        to: toShape;
						        width:
							        (((golap includesSelection: aGolapEdge node1) or: [
									          golap includesSelection: aGolapEdge node2 ])
								         ifTrue: [ 2 ]
								         ifFalse: [ 0.5 ]);
						        color: color.
					(self newLabelForEdge: aGolapEdge) ifNotNil: [ :label |
							line
								when: RSExtentChangedEvent
								do: [
										label
											position: line position;
											pushFront ]
								for: label.
							label position: line position.
							self canvas add: label.
							label pushFront ].
					^ line ] ].
	^ nil
]

{ #category : 'instance creation' }
GolapElaborationPresenter >> newShapeForRootNode: aGolapNode [

	self golapModelDo: [ :golapModel |
			| shapes markersAndNodes |
			shapes := RSGroup new.
			markersAndNodes := Array streamContents: [ :stream |
					                   golap markersAndNodesDo: [ :c :vs |
						                   c ifNotNil: [
							                   stream nextPut: c -> vs asIdentitySet ] ] ].
			(golap colorForNode: aGolapNode) ifNotNil: [ :color |
					| shape |
					shape := self newLabelForNode: aGolapNode.
					self canvas addNode: shape.
					nodes at: aGolapNode put: shape.
					shapes add: shape.
					markersAndNodes do: [ :colorAndVs |
							(colorAndVs value includes: aGolapNode) ifTrue: [
									shape := RSBox new
										         position: shape position;
										         extent: shape extent + 4 asPoint;
										         borderWidth: 4;
										         borderColor: colorAndVs key;
										         color: Color transparent;
										         yourself.
									shapes add: shape ] ].
					(golap includesPin: aGolapNode) ifTrue: [
						shapes add: self newPinShape ] ].
			shapes := shapes asShapeFor: aGolapNode.
			^ shapes ].
	^ nil
]

{ #category : 'accessing' }
GolapElaborationPresenter >> offset [

	^ offset
]

{ #category : 'accessing' }
GolapElaborationPresenter >> offset: aPoint [

	offset := aPoint
]

{ #category : 'rendering' }
GolapElaborationPresenter >> renderEdgesIn: aRSCanvas [

	rootNodes do: [ :rootNode |
			nodes at: rootNode ifPresent: [ :rootShape |
					rootNode edgesAndNodeDo: [ :edge :associateNode |
							nodes at: associateNode ifPresent: [ :associateShape |
									(self newShapeForEdge: edge) ifNotNil: [ :edgeShape |
											edgeShape @ edgeInteraction.
											aRSCanvas
												addLine: edgeShape;
												add: edgeShape ] ] ] ] ]
]

{ #category : 'rendering' }
GolapElaborationPresenter >> renderNodesIn: aRSCanvas [

	| gap |
	gap := gapSlider value.
	nodes := IdentityDictionary new.
	positions := IdentityDictionary new.
	associateBaseX := 0.
	(rootNodes collect: [ :rootNode | self newShapeForRootNode: rootNode ])
		ifNotEmpty: [ :nodeShapes |
				| shapeExtent |
				shapeExtent := (nodeShapes collect: #extent) max.
				associateBaseX := shapeExtent x.
				nodeShapes doWithIndex: [ :shape :index |
						| point nodeShape |
						nodeShape := {
							             (RSBox new
								              position: shapeExtent * 0.5;
								              extent: shapeExtent;
								              color: Color transparent;
								              yourself).
							             shape } asShapeFor: shape model.
						point := shapeExtent x * 0.5
						         @ (shapeExtent y + 2 * (index - 0.5) + 4).
						positions at: nodeShape put: point.
						nodes at: nodeShape model put: nodeShape.
						nodeShape translateTo: point + offset * scale.
						nodeShape @ nodeInteraction.
						aRSCanvas
							add: nodeShape;
							addNode: nodeShape ] ].
	(associateNodes collect: [ :associateNode |
		 self newShapeForAssociateNode: associateNode ]) ifNotEmpty: [
			:nodeShapes |
			| shapeExtent |
			shapeExtent := (nodeShapes collect: #extent) max.
			nodeShapes doWithIndex: [ :shape :index |
					| point nodeShape |
					nodeShape := {
						             (RSBox new
							              position: shapeExtent * 0.5;
							              extent: shapeExtent;
							              color: Color transparent;
							              yourself).
						             shape } asShapeFor: shape model.
					point := associateBaseX + gap + (shapeExtent x * 0.5)
					         @ (shapeExtent y + 10 * (index - 0.5)).
					positions at: nodeShape put: point.
					nodes at: nodeShape model put: nodeShape.
					nodeShape translateTo: point + offset * scale.
					nodeShape @ nodeInteraction.
					aRSCanvas
						add: nodeShape;
						addNode: nodeShape ] ]
]

{ #category : 'accessing' }
GolapElaborationPresenter >> scale [

	^ scale
]

{ #category : 'accessing' }
GolapElaborationPresenter >> scale: aPoint [

	scale := (aPoint x min: 3.0 max: 1.0) @ (aPoint y min: 4.0 max: 1.0)
]

{ #category : 'accessing' }
GolapElaborationPresenter >> scale: aNumber at: aPoint [

	| oldFocus newFocus |
	oldFocus := aPoint / scale.
	self scale: aNumber.
	newFocus := aPoint / scale.
	self offset: offset - oldFocus + newFocus
]

{ #category : 'testing' }
GolapElaborationPresenter >> showsNode: aGolapNode [

	^ (rootNodes includes: aGolapNode) or: [
		  associateNodes includes: aGolapNode ]
]

{ #category : 'updating' }
GolapElaborationPresenter >> updateAssociateNodePositions [

	| gap |
	gap := gapSlider value.
	associateNodes do: [ :associateNode |
			nodes at: associateNode ifPresent: [ :shape |
					positions at: shape ifPresent: [ :oldPosition |
							| newPosition |
							newPosition := associateBaseX + gap + (shape extent x * 0.5)
							               @ oldPosition y.
							positions at: shape put: newPosition.
							shape translateTo: newPosition + offset * scale ] ] ]
]

{ #category : 'updating' }
GolapElaborationPresenter >> updateCanvas [

	self isDisplayed ifTrue: [
		self updateGraph.
		self canvas shapes copy do: #remove.
		self canvas color: Color white.
		self
			renderNodesIn: self canvas;
			renderEdgesIn: self canvas.
		self canvas signalUpdate ]
]

{ #category : 'updating' }
GolapElaborationPresenter >> updateGraph [

	rootNodes := Array new.
	associateNodes := Array new.
	self golapModelDo: [ :model |
			| rootSet associateScores |
			rootNodes := ((golap markedNodes collect: [ :node |
				               node -> (model valueAtNode: node) ])
				              asSortedCollection: #value descending) collect: #key.
			rootSet := rootNodes asIdentitySet.
			associateScores := IdentityDictionary new: rootNodes size * 2.
			rootNodes do: [ :node |
					node edgesAndNodeDo: [ :edge :peer |
							(rootSet includes: peer) ifFalse: [
									associateScores
										at: peer
										put:
										(associateScores at: peer ifAbsent: [ 0 ])
										+ (model valueAtEdge: edge) ] ] ].
			associateNodes := (associateScores associations
				                   asSortedCollection: #value descending)
				                  collect: #key.
			barScale := associateNodes
				            ifNotEmpty: [
				            500.0 / associateScores values max asFloat ]
				            ifEmpty: [ 1.0 ] ].
	golap updateItemsList
]

{ #category : 'updating' }
GolapElaborationPresenter >> updateNodeShapePositions [

	self canvas shapes do: [ :shape |
			(shape model isKindOf: GolapNode) ifTrue: [
					positions
						at: shape
						ifPresent: [ :point | shape translateTo: point + offset * scale ] ] ]
]

{ #category : 'updating' }
GolapElaborationPresenter >> updateTree [

	self updateCanvas
]

{ #category : 'operations' }
GolapElaborationPresenter >> zoomInAt: aPoint [

	self scale: self scale * (1.1 @ 1.0) at: aPoint.
	self updateNodeShapePositions.
	self canvas signalUpdate
]

{ #category : 'operations' }
GolapElaborationPresenter >> zoomOutAt: aPoint [

	self scale: self scale / (1.1 @ 1.0) at: aPoint.
	self updateNodeShapePositions.
	self canvas signalUpdate
]

{ #category : 'operations' }
GolapElaborationPresenter >> zoomToFit [

	self isDisplayed ifTrue: [
			| rect |
			rect := positions values
				        ifEmpty: [ ^ self ]
				        ifNotEmpty: [ :points | Rectangle encompassing: points ].
			self scale: 1.0 @ 1.0.
			self offset: self extent * -0.5.
			self updateNodeShapePositions.
			self canvas signalUpdate ]
]
