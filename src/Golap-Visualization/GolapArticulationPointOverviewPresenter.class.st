Class {
	#name : 'GolapArticulationPointOverviewPresenter',
	#superclass : 'GolapOverviewPresenter',
	#instVars : [
		'friendsRankField',
		'layoutButton',
		'articulationPointList'
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

	golap ifNotNil: [
		self articulationPoint ifNotNil: [ :node |
			golap selections: { node }.
			offset := node asPoint negated.
			self updateNodePositions ] ]
]

{ #category : 'accessing' }
GolapArticulationPointOverviewPresenter >> availableEdges [

	^ (self golapModelDo: [ :golapModel |
		   golapModel friendsEdges: friendsRankField number ]) ifNil: [
		  Array new ]
]

{ #category : 'layout' }
GolapArticulationPointOverviewPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: 'フレンドランク ' asPresenter expand: false;
				   add: friendsRankField width: 50;
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
		                    whenSubmitDo: [ :txt | self friendsRankChanged ];
		                    yourself.
	layoutButton := self newButton
		                label: ' 再配置 ';
		                action: [
				                golap
					                updateGlobalImageAfter: [
						                golap model friendsEdges:
								                friendsRankField number ]
					                layout: true.
				                self zoomToFit ];
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

{ #category : 'instance creation' }
GolapArticulationPointOverviewPresenter >> newShapeForEdge: aGolapEdge [

	^ (super newShapeForEdge: aGolapEdge) ifNotNil: [ :line |
		  self articulationPoint ifNotNil: [ :node |
			  (aGolapEdge hasNode: node) ifTrue: [ line dashArray: #( 2 4 ) ] ].
		  line ]
]

{ #category : 'accessing' }
GolapArticulationPointOverviewPresenter >> photoimageExtent [

	^ 64 asPoint
]

{ #category : 'accessing' }
GolapArticulationPointOverviewPresenter >> sumNeighborsOrdersOf: aGolapNode [

	| sum |
	sum := 0.
	aGolapNode edgesAndNodeDo: [ :edge :peer |
			(reallyVisibleEdges includes: edge) ifTrue: [
					peer edgesAndNodeDo: [ :e :p |
							(aGolapNode ~~ p and: [ reallyVisibleEdges includes: e ])
								ifTrue: [ sum := sum + 1 ] ] ] ].
	^ sum
]

{ #category : 'updating' }
GolapArticulationPointOverviewPresenter >> updateArticulationPointList [

	self golapModelDo: [ :golapModel |
			articulationPointList items:
				((((golapModel articulationNodesInEdges: reallyVisibleEdges)
					   collect: [ :node | node -> (self sumNeighborsOrdersOf: node) ])
					  asSortedCollection: #value descending) collect: #key) ]
]

{ #category : 'updating' }
GolapArticulationPointOverviewPresenter >> updateGraph [

	super updateGraph.
	self updateArticulationPointList
]
