Class {
	#name : 'GolapArticulationPointOverviewPresenter',
	#superclass : 'GolapOverviewPresenter',
	#instVars : [
		'friendsRankField',
		'minimumIslandSizeField',
		'layoutButton',
		'articulationPointList',
		'islandNodeSets'
	],
	#category : 'Golap-Visualization-ArticulationPoint',
	#package : 'Golap-Visualization',
	#tag : 'ArticulationPoint'
}

{ #category : 'accessing' }
GolapArticulationPointOverviewPresenter >> articulationPoint [

	^ articulationPointList selectedItem
]

{ #category : 'updating' }
GolapArticulationPointOverviewPresenter >> articulationPointChanged [

	self updateIslandNodeSets.
	golap ifNotNil: [
			self updateCanvas.
			self articulationPoint ifNotNil: [ :node |
				offset := (nodePositions at: node id) negated ].
			self updateNodeShapePositions ]
]

{ #category : 'snapshot' }
GolapArticulationPointOverviewPresenter >> asJSON [

	^ super asJSON
		  at: 'friendsRank' put: friendsRankField number;
		  at: 'minimumIslandSize' put: minimumIslandSizeField number;
		  at: 'articulationPoint'
		  put: (articulationPointList selectedItem ifNotNil: #id);
		  yourself
]

{ #category : 'accessing' }
GolapArticulationPointOverviewPresenter >> availableEdges [

	^ (self golapModelDo: [ :golapModel |
		   golapModel friendsEdges: friendsRankField number ]) ifNil: [
		  Array new ]
]

{ #category : 'accessing' }
GolapArticulationPointOverviewPresenter >> colorForEdge: aGolapEdge [

	(aGolapEdge hasNode: self articulationPoint) ifTrue: [ ^ Color black ].
	islandNodeSets
		ifNotEmpty: [
			islandNodeSets withIndexDo: [ :set :index |
				((set includes: aGolapEdge node1) or: [
					 set includes: aGolapEdge node2 ]) ifTrue: [
					^ Color
						  h: index - 1 * 360 / islandNodeSets size asFloat
						  s: 0.8
						  l: 0.3 ] ].
			^ nil ]
		ifEmpty: [ ^ super colorForEdge: aGolapEdge ]
]

{ #category : 'accessing' }
GolapArticulationPointOverviewPresenter >> colorForNode: aGolapNode [

	aGolapNode = self articulationPoint ifTrue: [ ^ Color black ].
	islandNodeSets
		ifNotEmpty: [
			islandNodeSets withIndexDo: [ :set :index |
				(set includes: aGolapNode) ifTrue: [
					^ Color
						  h: index - 1 * 360 / islandNodeSets size asFloat
						  s: 0.8
						  l: 0.3 ] ].
			^ nil ]
		ifEmpty: [ ^ super colorForNode: aGolapNode ]
]

{ #category : 'layout' }
GolapArticulationPointOverviewPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: 'フレンドランク ' asPresenter expand: false;
				   add: friendsRankField width: 50;
				   add: '島の最小サイズ' asPresenter expand: false;
				   add: minimumIslandSizeField width: 50;
				   add: '    ' asPresenter expand: false;
				   add: layoutButton expand: false;
				   yourself)
		  expand: false;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 0.25;
				   add: articulationPointList;
				   add: roassal;
				   yourself)
		  expand: true;
		  yourself
]

{ #category : 'updating' }
GolapArticulationPointOverviewPresenter >> friendsRankChanged [

	self golapModelDo: [ :golapModel |
		golapModel friendsEdges: friendsRankField number ].
	self updateCanvas
]

{ #category : 'initialization' }
GolapArticulationPointOverviewPresenter >> initializePresenters [

	super initializePresenters.
	friendsRankField := self newNumberInput
		                    beInteger;
		                    placeholder: 'フレンドランク数';
		                    minimum: 1;
		                    number: 5;
		                    autoAccept: true;
		                    whenNumberChangedDo: [ self friendsRankChanged ];
		                    yourself.
	minimumIslandSizeField := self newNumberInput
		                          beInteger;
		                          placeholder: '島の最小サイズ';
		                          minimum: 1;
		                          number: 2;
		                          autoAccept: true;
		                          whenNumberChangedDo: [
			                          self minimumIslandSizeChanged ];
		                          yourself.
	layoutButton := self newButton
		                label: ' 再配置 ';
		                action: [
				                golap
					                updateGlobalImageAfter: [
						                golap model friendsEdges:
								                friendsRankField number ]
					                layout: false.
				                self updateNodePositions ];
		                yourself.
	articulationPointList := self newTable
		                         hideColumnHeaders;
		                         addColumn:
			                         ((SpImageTableColumn evaluated: [ :node |
					                           node photoimage ]) width:
					                          self photoimageExtent x);
		                         addColumn:
			                         (SpStringTableColumn evaluated: [ :node |
					                          node name ]);
		                         activateOnDoubleClick;
		                         whenActivatedDo: [ :selection |
				                         articulationPointList selectedItem
				                         == selection selectedItem ifTrue: [
						                         articulationPointList unselectAll ] ];
		                         whenSelectionChangedDo: [
			                         self articulationPointChanged ];
		                         whenBuiltDo: [
				                         articulationPointList withAdapterDo: [ :a |
							                         a widgetDo: [ :w |
										                         w
											                         rowHeight: self photoimageExtent y;
											                         refresh ] ] ];
		                         yourself
]

{ #category : 'accessing' }
GolapArticulationPointOverviewPresenter >> islandsDividedByArticulationPoint: aGolapNode [

	| edges nodeSets startNodes |
	edges := self availableEdges asIdentitySet.
	nodeSets := OrderedCollection new.
	startNodes := OrderedCollection new.
	aGolapNode edgesAndNodeDo: [ :edge :peer |
			(edges remove: edge ifAbsent: [ nil ]) ifNotNil: [
				startNodes add: peer ] ].
	startNodes do: [ :node |
			(nodeSets anySatisfy: [ :set | set includes: node ]) ifFalse: [
					| nodeSet |
					nodeSet := IdentitySet new.
					nodeSets add: nodeSet.
					self withEdges: edges search: node nodeSet: nodeSet ] ].
	^ nodeSets asSortedCollection: #size descending
]

{ #category : 'accessing' }
GolapArticulationPointOverviewPresenter >> minimumIslandSize [

	^ minimumIslandSizeField number ifNil: [ 1 ]
]

{ #category : 'updating' }
GolapArticulationPointOverviewPresenter >> minimumIslandSizeChanged [

	self updateArticulationPointList
]

{ #category : 'instance creation' }
GolapArticulationPointOverviewPresenter >> newShapeForEdge: aGolapEdge [

	^ (super newShapeForEdge: aGolapEdge) ifNotNil: [ :line |
		  self articulationPoint ifNotNil: [ :node |
			  (aGolapEdge hasNode: node) ifTrue: [ line dashArray: #( 2 4 ) ] ].
		  line ]
]

{ #category : 'instance creation' }
GolapArticulationPointOverviewPresenter >> newShapeForNode: aGolapNode [

	self golapModelDo: [ :golapModel |
			| shapes color |
			shapes := RSGroup new.
			(self colorForNode: aGolapNode) ifNotNil: [ :c |
					| v r shape |
					color := c.
					v := golapModel valueAtNode: aGolapNode.
					r := (v abs + 0.1) log - 1.0 log * freqScale max: 10.
					shape := aGolapNode photoimage
						         ifNotNil: [ :form |
								         {
									         (RSBox new
										          extent: form extent + (6 @ 6);
										          color: color).
									         (RSBitmap new
										          form: form;
										          model: #photoimage) } asShape ]
						         ifNil: [
								         RSCircle new
									         extent: r asPoint;
									         color: color;
									         model: #photoimage ].
					self canvas addNode: shape.
					nodeShapes at: aGolapNode put: shape.
					shapes add: shape.
					golap markersAtNode: aGolapNode do: [ :marker |
							shape := RSEllipse new
								         extent:
									         (shape extent x max: shape extent y) + 4 asPoint;
								         borderWidth: 4;
								         borderColor: marker color;
								         color: Color transparent;
								         yourself.
							shapes add: shape ].
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
			(aGolapNode photoimage isNil or: [
				 golap includesSelection: aGolapNode ]) ifTrue: [
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
GolapArticulationPointOverviewPresenter >> photoimageExtent [

	^ 64 asPoint
]

{ #category : 'accessing' }
GolapArticulationPointOverviewPresenter >> sumNeighborsOrdersOf: aGolapNode [

	| sum |
	sum := 0.
	self golapModelDo: [ :golapModel |
			aGolapNode edgesAndNodeDo: [ :edge :peer |
					((reallyVisibleEdges includes: edge) and: [
						 (golapModel isReferenceEdge: edge) not ]) ifTrue: [
							peer edgesAndNodeDo: [ :e :p |
									(aGolapNode ~~ p and: [
											 (reallyVisibleEdges includes: e) and: [
												 (golapModel isReferenceNode: p) not ] ]) ifTrue: [
										sum := sum + 1 ] ] ] ] ].
	^ sum
]

{ #category : 'updating' }
GolapArticulationPointOverviewPresenter >> updateArticulationPointList [

	lock critical: [
			self golapModelDo: [ :golapModel |
					| minimumIslandSize items |
					minimumIslandSize := self minimumIslandSize.
					items := (((golapModel articulationNodesInEdges:
						            (reallyVisibleEdges select: [ :edge |
							             (golapModel isReferenceEdge: edge) not ]))
						           collect: [ :node |
						           node
						           -> (self islandsDividedByArticulationPoint: node) ]
						           thenSelect: [ :assoc |
								           (assoc value select: [ :island |
									            island size >= minimumIslandSize ]) size >= 2 ])
						          asSortedCollection: [ :more :less |
								          less value size < more value size or: [
										          less value size = more value size and: [
											          (less value at: 2) size < (more value at: 2) size ] ] ])
						         collect: #key.
					items ~= articulationPointList items ifTrue: [
						articulationPointList items: items ] ] ]
]

{ #category : 'updating' }
GolapArticulationPointOverviewPresenter >> updateGraph [

	super updateGraph.
	self updateArticulationPointList
]

{ #category : 'updating' }
GolapArticulationPointOverviewPresenter >> updateIslandNodeSets [

	| minimumIslandSize |
	minimumIslandSize := self minimumIslandSize.
	islandNodeSets := self articulationPoint
		                  ifNotNil: [ :articulationNode |
			                  self islandsDividedByArticulationPoint:
				                  articulationNode ]
		                  ifNil: [
				                  | startNodes edges nodeSets |
				                  startNodes := IdentitySet new.
				                  edges := IdentitySet new.
				                  self availableEdges do: [ :edge |
						                  startNodes
							                  add: edge node1;
							                  add: edge node2.
						                  edges add: edge ].
				                  nodeSets := OrderedCollection new.
				                  [ startNodes notEmpty ] whileTrue: [
						                  | node nodeSet |
						                  node := startNodes anyOne.
						                  nodeSet := IdentitySet new.
						                  nodeSets add: nodeSet.
						                  self
							                  withEdges: edges
							                  search: node
							                  nodeSet: nodeSet.
						                  startNodes removeAll: nodeSet ].
				                  (nodeSets select: [ :set |
					                   set size >= minimumIslandSize ])
					                  asSortedCollection: #size descending ]
]

{ #category : 'private' }
GolapArticulationPointOverviewPresenter >> withEdges: anIdentitySetOfGolapEdge search: aGolapNode nodeSet: anIdentitySetOfGolapNode [

	anIdentitySetOfGolapNode add: aGolapNode.
	aGolapNode edgesAndNodeDo: [ :edge :peer |
		((anIdentitySetOfGolapEdge includes: edge) and: [
			 (anIdentitySetOfGolapNode includes: peer) not ]) ifTrue: [
			self
				withEdges: anIdentitySetOfGolapEdge
				search: peer
				nodeSet: anIdentitySetOfGolapNode ] ]
]
