Class {
	#name : 'GolapOverviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'roassal',
		'scale',
		'offset',
		'golap',
		'nodePositions',
		'reallyVisibleEdges',
		'reallyVisibleNodes',
		'freqScale',
		'lineScale',
		'referenceNodes',
		'selectedReferenceNodes',
		'activeReferenceNodes',
		'lock',
		'nodeShapes'
	],
	#category : 'Golap-Visualization-Overview',
	#package : 'Golap-Visualization',
	#tag : 'Overview'
}

{ #category : 'testing' }
GolapOverviewPresenter class >> isAbstract [

	^ self = GolapOverviewPresenter
]

{ #category : 'updating' }
GolapOverviewPresenter >> activateOnNotebookPage [

	nodePositions ifEmpty: [ self updateNodePositions ]
]

{ #category : 'accessing' }
GolapOverviewPresenter >> availableEdges [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapOverviewPresenter >> camera [

	^ self canvas camera
]

{ #category : 'accessing' }
GolapOverviewPresenter >> cameraScale [

	^ self camera scale
]

{ #category : 'accessing' }
GolapOverviewPresenter >> cameraScale: aNumber [

	self camera scale: aNumber
]

{ #category : 'accessing' }
GolapOverviewPresenter >> canvas [

	^ roassal canvas
]

{ #category : 'accessing' }
GolapOverviewPresenter >> colorForEdge: aGolapEdge [

	^ golap colorForEdge: aGolapEdge
]

{ #category : 'accessing' }
GolapOverviewPresenter >> colorForNode: aGolapNode [

	^ golap colorForNode: aGolapNode
]

{ #category : 'layout' }
GolapOverviewPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: roassal expand: true;
		  yourself
]

{ #category : 'private' }
GolapOverviewPresenter >> edgeVectorOf: aGolapNode [

	| v |
	v := 0 @ 0.
	nodePositions at: aGolapNode ifPresent: [ :p0 |
			aGolapNode edgesAndNodeDo: [ :edge :node |
					(reallyVisibleEdges includes: edge) ifTrue: [
							nodePositions at: node ifPresent: [ :p1 |
									| v1 |
									v1 := p1 - p0.
									v1 isZero ifFalse: [ v := v + v1 normalized ] ] ] ] ].
	^ v isZero
		  ifTrue: [ v ]
		  ifFalse: [ v normalized ]
]

{ #category : 'updating' }
GolapOverviewPresenter >> ensureNodePositions [

	self isDisplayed ifTrue: [
			self golapModelDo: [ :golapModel |
					self availableEdges do: [ :edge |
							((golapModel valueAtEdge: edge) notNil and: [
									 (nodePositions includesKey: edge node1) not or: [
										 (nodePositions includesKey: edge node2) not ] ]) ifTrue: [
									nodePositions := GolapOverviewGridLayouter
										                 layoutNodes: reallyVisibleNodes
										                 edges: reallyVisibleEdges.
									self
										updateNodeShapes;
										forceZoomToFit.
									^ self ] ] ] ]
]

{ #category : 'operations' }
GolapOverviewPresenter >> forceZoomToFit [

	| rect ext |
	rect := (Array streamContents: [ :stream |
			         reallyVisibleNodes do: [ :node |
				         nodePositions
					         at: node
					         ifPresent: [ :point | stream nextPut: point ] ] ])
		        ifEmpty: [ ^ self ]
		        ifNotEmpty: [ :points | Rectangle encompassing: points ].
	self offset: rect floatCenter negated.
	roassal withAdapterDo: [ :a |
			a widgetDo: [ :w |
					ext := w extent.
					self scale: (ext x / rect width min: ext y / rect height) * 0.9 ] ].
	self updateNodeShapePositions.
	self canvas signalUpdate
]

{ #category : 'private' }
GolapOverviewPresenter >> fourDirectionFrom: aPoint [

	| norm x y |
	aPoint isZero ifTrue: [ ^ 0 @ 1 ].
	norm := aPoint normalized.
	x := norm x.
	y := norm y.
	^ x abs <= y abs
		  ifTrue: [ 0 @ y sign ]
		  ifFalse: [ x sign @ 0 ]
]

{ #category : 'accessing' }
GolapOverviewPresenter >> golap: aGolap [
	golap := aGolap.
	self golapChanged
]

{ #category : 'updating' }
GolapOverviewPresenter >> golapChanged [

	self updateNodePositions
]

{ #category : 'enumerating' }
GolapOverviewPresenter >> golapDo: aBlock [

	^ golap ifNotNil: aBlock
]

{ #category : 'enumerating' }
GolapOverviewPresenter >> golapModelDo: aBlock [

	^ golap ifNotNil: [ golap model ifNotNil: aBlock ]
]

{ #category : 'initialization' }
GolapOverviewPresenter >> initialize [

	super initialize.
	scale := 100.0.
	offset := 0.0 @ 0.0.
	lock := Semaphore forMutualExclusion.
	nodePositions := IdentityDictionary new
]

{ #category : 'initialization' }
GolapOverviewPresenter >> initializePresenters [

	super initializePresenters.
	roassal := self newRoassal
		           canvas: RSCanvas new @ self newCanvasController;
		           yourself
]

{ #category : 'operations' }
GolapOverviewPresenter >> move: aPoint [

	self offset: aPoint / scale + offset.
	self updateNodeShapePositions.
	self canvas signalUpdate
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newCanvasController [

	^ GolapOverviewController new
		  presenter: self;
		  yourself
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newLabelForEdge: aGolapEdge [

	^ self golapModelDo: [ :golapModel |
			  (self colorForEdge: aGolapEdge) ifNotNil: [ :color |
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
GolapOverviewPresenter >> newLabelForNode: aGolapNode [

	^ self golapModelDo: [ :model |
			  (self colorForNode: aGolapNode) ifNotNil: [ :color |
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
					  (golap includesSelection: aGolapNode) ifTrue: [
							  label := {
								           (RSBox new
									            extent: label extent;
									            position: label position;
									            color: Color white;
									            borderColor: color;
									            borderWidth: 1;
									            yourself).
								           label } asShape ].
					  label ] ]
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newLabelFromLines: anArrayOfString color: aColor [

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
GolapOverviewPresenter >> newPinShape [

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
GolapOverviewPresenter >> newShapeForEdge: aGolapEdge [

	self golapModelDo: [ :golapModel |
		(((referenceNodes includes: aGolapEdge node1 id) or: [
			  referenceNodes includes: aGolapEdge node2 id ])
			 ifTrue: [
				 ((selectedReferenceNodes includes: aGolapEdge node1) or: [
					  selectedReferenceNodes includes: aGolapEdge node2 ])
					 ifTrue: [
						 | refIndex |
						 refIndex := (activeReferenceNodes indexOf: aGolapEdge node1)
							             max:
							             (activeReferenceNodes indexOf: aGolapEdge node2).
						 refIndex > 0
							 ifTrue: [
								 Color
									 h:
									 (refIndex - 1) asFloat * 360.0
									 / activeReferenceNodes size asFloat
									 s: 1.0
									 v: 1.0 ]
							 ifFalse: [ nil ] ]
					 ifFalse: [ nil ] ]
			 ifFalse: [ self colorForEdge: aGolapEdge ]) ifNotNil: [ :color |
			| fromShape toShape v line |
			fromShape := nodeShapes at: aGolapEdge node1 ifAbsent: [ ^ nil ].
			toShape := nodeShapes at: aGolapEdge node2 ifAbsent: [ ^ nil ].
			v := golapModel valueAtEdge: aGolapEdge.
			(v notNil and: [ v asFloat isFinite ]) ifFalse: [ ^ nil ].
			line := RSLine new
				        model: aGolapEdge;
				        withCenteredAttachPoint;
				        from: fromShape;
				        to: toShape;
				        width: v asFloat abs * lineScale + 2.0;
				        color: color.
			(self newLabelForEdge: aGolapEdge) ifNotNil: [ :label |
				line
					when: RSExtentChangedEvent
					do: [ label position: line position ]
					for: label.
				label position: line position.
				self canvas add: label ].
			^ line ] ].
	^ nil
]

{ #category : 'instance creation' }
GolapOverviewPresenter >> newShapeForNode: aGolapNode [

	self golapModelDo: [ :golapModel |
		| shapes markersAndNodes color |
		shapes := RSGroup new.
		markersAndNodes := Array streamContents: [ :stream |
			                   golap markersAndNodesDo: [ :c :vs |
				                   c ifNotNil: [
					                   stream nextPut: c -> vs asIdentitySet ] ] ].
		(self colorForNode: aGolapNode) ifNotNil: [ :c |
			| v r shape |
			color := c.
			v := golapModel valueAtNode: aGolapNode.
			r := (v abs + 0.1) log - 1.0 log * freqScale max: 10.
			shape := aGolapNode photoimage
				         ifNotNil: [ :form |
					         RSBitmap new
						         form: form;
						         model: #photoimage ]
				         ifNil: [
					         RSCircle new
						         extent: r asPoint;
						         color: color;
						         model: #photoimage ].
			self canvas addNode: shape.
			nodeShapes at: aGolapNode put: shape.
			shapes add: shape.
			markersAndNodes do: [ :colorAndVs |
				(colorAndVs value includes: aGolapNode) ifTrue: [
					shape := RSEllipse new
						         extent:
							         (shape extent x max: shape extent y) + 4 asPoint;
						         borderWidth: 4;
						         borderColor: colorAndVs key;
						         color: Color transparent;
						         yourself.
					shapes add: shape ] ].
			golap selectedBaseDimension ifNotNil: [
				| p |
				p := shape extent x * 0.5 + 4.0 @ 0.
				shapes add: (RSArrowedLine new
						 startPoint: p;
						 endPoint: p + (0 @ (r * v sign negated));
						 color: color;
						 width: 2;
						 yourself) ].
			(golap includesPin: aGolapNode) ifTrue: [
				shapes add: self newPinShape ] ].
		shapes ifEmpty: [ ^ nil ].
		shapes := shapes asShapeFor: aGolapNode.
		aGolapNode photoimage ifNil: [
			(self newLabelForNode: aGolapNode) ifNotNil: [ :label |
				| labelOffset |
				labelOffset := (self fourDirectionFrom:
					                (self edgeVectorOf: aGolapNode)) negated
				               * (shapes extent + label extent * 0.5 + 4).
				shapes
					when: RSPositionChangedEvent
					do: [ label position: shapes position + labelOffset ]
					for: label.
				label position: shapes position + labelOffset.
				self canvas add: label ] ].
		^ shapes ].
	^ nil
]

{ #category : 'accessing' }
GolapOverviewPresenter >> offset [

	^ offset
]

{ #category : 'accessing' }
GolapOverviewPresenter >> offset: aPoint [

	offset := aPoint
]

{ #category : 'rendering' }
GolapOverviewPresenter >> renderEdgesIn: aRSCanvas [

	| edgeInteraction |
	edgeInteraction := GolapOverviewEdgeInteraction new
		                   presenter: self;
		                   yourself.
	reallyVisibleEdges do: [ :edge |
			(self newShapeForEdge: edge) ifNotNil: [ :line |
					line @ edgeInteraction.
					aRSCanvas
						add: line;
						addLine: line.
					line pushBack ] ]
]

{ #category : 'rendering' }
GolapOverviewPresenter >> renderNodesIn: aRSCanvas [

	| interaction |
	interaction := GolapOverviewNodeInteraction new
		               presenter: self;
		               yourself.
	nodeShapes := IdentityDictionary new: reallyVisibleNodes size.
	reallyVisibleNodes do: [ :node |
			nodePositions at: node ifPresent: [ :p |
					(self newShapeForNode: node) ifNotNil: [ :shape |
							shape translateTo: p + offset * scale.
							shape @ interaction.
							self canvas add: shape ] ] ]
]

{ #category : 'accessing' }
GolapOverviewPresenter >> scale [

	^ scale
]

{ #category : 'accessing' }
GolapOverviewPresenter >> scale: aNumber [

	scale := aNumber
]

{ #category : 'accessing' }
GolapOverviewPresenter >> scale: aNumber at: aPoint [

	| oldFocus newFocus |
	oldFocus := aPoint / scale.
	self scale: aNumber.
	newFocus := aPoint / scale.
	self offset: offset - oldFocus + newFocus
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateCanvas [

	self isDisplayed ifTrue: [
			self
				updateGraph;
				updateNodeShapes ]
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateFreqScale [

	self golapModelDo: [ :golapModel |
			freqScale := 30.0 / ((golap nodes collect: [ :node |
				               ((golapModel valueAtNode: node) abs + 0.1) log
				               - 1.0 log ]) ifEmpty: [ 1 ] ifNotEmpty: #max) ]
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateGraph [

	lock critical: [
			self golapModelDo: [ :model |
					| visibleEdges connectedNodes |
					visibleEdges := self availableEdges select: [ :edge |
						                (model valueAtEdge: edge) notNil ].
					reallyVisibleEdges := visibleEdges.
					connectedNodes := IdentitySet new: reallyVisibleEdges size.
					reallyVisibleEdges do: [ :edge |
							connectedNodes
								add: edge node1;
								add: edge node2 ].
					reallyVisibleNodes := Array streamContents: [ :stream |
							                      golap showsConnectedNodes ifTrue: [
								                      stream nextPutAll: connectedNodes ].
							                      self nodesDo: [ :v |
									                      (connectedNodes includes: v) ifFalse: [
											                      v isIsolated
												                      ifTrue: [
												                      golap showsIsolatedNodes ifTrue: [
													                      stream nextPut: v ] ]
												                      ifFalse: [
												                      golap showsHiddenConnectionNodes
													                      ifTrue: [ stream nextPut: v ] ] ] ] ] ] ]
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateLineScale [

	| edgeScale maxValue |
	edgeScale := golap edgeScale.
	edgeScale < 1.0e-6 ifTrue: [ ^ self ].
	reallyVisibleEdges ifEmpty: [ ^ self ].
	maxValue := (reallyVisibleEdges
		             collect: [ :e |
		             (golap model valueAtEdge: e) ifNotNil: #abs ]
		             thenSelect: [ :v |
		             v notNil and: [ v isNaN not and: [ v isInfinite not ] ] ])
		            ifEmpty: [ 0 ]
		            ifNotEmpty: #max.
	lineScale := maxValue >= 1.0e-8
		             ifTrue: [ 5.0 / maxValue * edgeScale ]
		             ifFalse: [ 2.0 ].
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateNodePositions [

	self isDisplayed ifTrue: [
			self updateGraph.
			(reallyVisibleNodes notNil and: [ reallyVisibleEdges notNil ])
				ifTrue: [
						nodePositions := GolapOverviewGridLayouter
							                 layoutNodes: reallyVisibleNodes
							                 edges: reallyVisibleEdges.
						self
							updateNodeShapes;
							forceZoomToFit ] ]
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateNodeShapePositions [

	lock critical: [
		self canvas shapes do: [ :shape |
			nodePositions
				at: shape model
				ifPresent: [ :point | shape translateTo: point + offset * scale ] ] ]
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateNodeShapes [

	lock critical: [
		self
			updateFreqScale;
			updateLineScale;
			updateReferenceNodes.
		self canvas shapes copy do: #remove.
		self canvas color: Color white.
		self
			renderNodesIn: self canvas;
			renderEdgesIn: self canvas.
		self canvas signalUpdate ]
]

{ #category : 'updating' }
GolapOverviewPresenter >> updateReferenceNodes [

	referenceNodes := golap referenceNodes.
	selectedReferenceNodes := (referenceNodes
		                           collect: [ :id | golap model nodeAt: id ]
		                           thenSelect: [ :node |
		                           golap includesSelection: node ])
		                          asIdentitySet.
	selectedReferenceNodes addAll: golap selections.
	activeReferenceNodes := referenceNodes collect: [ :id | "  thenSelect: [ :node |
				                        (golap includesSelection: node) or: [
					                        node hasPeerSuchThat: [ :peer |
						                        golap includesSelection: peer ] ] ]"
		                        golap model nodeAt: id ]
]

{ #category : 'operations' }
GolapOverviewPresenter >> zoomInAt: aPoint [

	self scale: self scale * 1.1 at: aPoint.
	self updateNodeShapePositions.
	self canvas signalUpdate
]

{ #category : 'operations' }
GolapOverviewPresenter >> zoomOutAt: aPoint [

	self scale: self scale / 1.1 at: aPoint.
	self updateNodeShapePositions.
	self canvas signalUpdate
]

{ #category : 'operations' }
GolapOverviewPresenter >> zoomToFit [

	self isDisplayed ifTrue: [ self forceZoomToFit ]
]
