Class {
	#name : 'GolapPolishOverviewPresenter',
	#superclass : 'GolapOverviewPresenter',
	#instVars : [
		'layoutButton',
		'applyButton',
		'fillerThresholdField',
		'fillerThresholdSlider',
		'minClusterSizeField',
		'burrThresholdField',
		'burrThresholdSlider',
		'polisher',
		'polishToConvergeCheckBox'
	],
	#category : 'Golap-Visualization-Polish',
	#package : 'Golap-Visualization',
	#tag : 'Polish'
}

{ #category : 'operations' }
GolapPolishOverviewPresenter >> applyPolish [

	self golapModelDo: [ :golapModel |
			polisher applyTo: golapModel.
			polisher reset.
			self updateCanvas ]
]

{ #category : 'accessing' }
GolapPolishOverviewPresenter >> availableEdges [

	^ Array streamContents: [ :stream |
			  self golapModelDo: [ :golapModel |
					  golapModel edgesDo: [ :edge | stream nextPut: edge ].
					  polisher fillerEdgeKeysDo: [ :edgeKey |
							  stream nextPut: (GolapEdge
									   on: nil
									   between: (golapModel nodeAt: edgeKey first)
									   and: (golapModel nodeAt: edgeKey second)) ] ] ]
]

{ #category : 'layout' }
GolapPolishOverviewPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: (SpBoxLayout newVertical
						    vAlignStart;
						    add: '研磨' asPresenter expand: false;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newVertical
						    add: (SpBoxLayout newHorizontal
								     add: '最小関連数' expand: false;
								     add: minClusterSizeField width: 50;
								     yourself)
						    expand: false;
						    add: polishToConvergeCheckBox width: 100;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newVertical
						    add: burrThresholdSlider expand: true;
						    add: fillerThresholdSlider expand: true;
						    yourself)
				   expand: true;
				   add: (SpBoxLayout newVertical
						    add: burrThresholdField expand: false;
						    add: fillerThresholdField expand: false;
						    yourself)
				   width: 50;
				   add: (SpBoxLayout newVertical
						    add: '研磨実行' asPresenter expand: false;
						    add: applyButton expand: false;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newVertical
						    add: '更新' asPresenter expand: false;
						    add: layoutButton expand: false;
						    yourself)
				   expand: false;
				   yourself)
		  expand: false;
		  add: roassal expand: true;
		  yourself
]

{ #category : 'initialization' }
GolapPolishOverviewPresenter >> initialize [

	super initialize.
	polisher := GolapPolisher new
]

{ #category : 'initialization' }
GolapPolishOverviewPresenter >> initializePresenters [

	super initializePresenters.
	polishToConvergeCheckBox := self newCheckBox
		                            label: '繰り返し';
		                            state: false;
		                            whenChangedDo: [ self updateCanvas ];
		                            yourself.
	fillerThresholdSlider := self newSlider
		                         label: '+研磨';
		                         min: 0.0;
		                         max: 1.0;
		                         value: 1.0;
		                         quantum: 0.01;
		                         whenValueChangedDo: [
			                         fillerThresholdField number:
					                         fillerThresholdSlider value ];
		                         borderWidth: 0;
		                         yourself.
	fillerThresholdField := self newNumberInput
		                        beFloat;
		                        placeholder: '+研磨';
		                        minimum: 0.8;
		                        maximum: 1.0;
		                        number: 1.0;
		                        whenNumberChangedDo: [ :num |
				                        fillerThresholdSlider value:
						                        fillerThresholdField number.
				                        self updateCanvas ].
	burrThresholdSlider := self newSlider
		                       label: '-研磨';
		                       min: 0.0;
		                       max: 0.2;
		                       value: 0.0;
		                       quantum: 0.01;
		                       whenValueChangedDo: [
			                       burrThresholdField number:
					                       burrThresholdSlider value ];
		                       borderWidth: 0;
		                       yourself.
	burrThresholdField := self newNumberInput
		                      beFloat;
		                      placeholder: '-研磨';
		                      minimum: 0.0;
		                      maximum: 0.2;
		                      number: 0.0;
		                      whenNumberChangedDo: [ :num |
				                      burrThresholdSlider value:
						                      burrThresholdField number.
				                      self updateCanvas ].
	minClusterSizeField := self newNumberInput
		                       beInteger;
		                       placeholder: '最小関連数';
		                       minimum: 1;
		                       number: 3;
		                       whenNumberChangedDo: [ :num |
			                       self updateCanvas ].
	applyButton := self newButton
		               label: '適用';
		               action: [ self applyPolish ];
		               yourself.
	layoutButton := self newButton
		                label: ' 再配置 ';
		                action: [ self updateNodePositions ];
		                yourself
]

{ #category : 'testing' }
GolapPolishOverviewPresenter >> isBurrEdge: aGolapEdge [

	^ polisher isBurrEdge: aGolapEdge
]

{ #category : 'testing' }
GolapPolishOverviewPresenter >> isFillerEdge: aGolapEdge [

	^ polisher isFillerEdge: aGolapEdge
]

{ #category : 'instance creation' }
GolapPolishOverviewPresenter >> newShapeForEdge: aGolapEdge [

	^ (super newShapeForEdge: aGolapEdge) ifNotNil: [ :line |
			  (self isFillerEdge: aGolapEdge) ifTrue: [
				  line color: golap positivePolishColor ].
			  (self isBurrEdge: aGolapEdge) ifTrue: [
					  line
						  color: golap negativePolishColor;
						  dashArray: #( 2 6 ) ].
			  line ]
]

{ #category : 'rendering' }
GolapPolishOverviewPresenter >> renderEdgesIn: aRSCanvas [

	super renderEdgesIn: aRSCanvas.
	aRSCanvas lines do: [ :line |
			line parent ifNotNil: [
					line model ifNotNil: [ :edge |
						(polisher isFillerEdge: edge) ifTrue: [ line pushFront ] ] ] ]
]

{ #category : 'updating' }
GolapPolishOverviewPresenter >> updateCanvas [

	polisher reset.
	self golapModelDo: [ :golapModel |
			polishToConvergeCheckBox state
				ifTrue: [
						polisher
							fitToConverge: golapModel
							fillerThreshold: fillerThresholdField number
							burrThreshold: burrThresholdField number
							minClusterSize: minClusterSizeField number ]
				ifFalse: [
						polisher
							fit: golapModel
							fillerThreshold: fillerThresholdField number
							burrThreshold: burrThresholdField number
							minClusterSize: minClusterSizeField number ] ].
	super updateCanvas
]

{ #category : 'updating' }
GolapPolishOverviewPresenter >> updateGraph [

	lock critical: [
			self golapModelDo: [ :model |
					| visibleEdges connectedNodes |
					visibleEdges := self availableEdges.
					reallyVisibleEdges := visibleEdges.
					connectedNodes := IdentitySet new: reallyVisibleEdges size.
					reallyVisibleEdges do: [ :edge |
							connectedNodes
								add: edge node1;
								add: edge node2 ].
					reallyVisibleNodes := connectedNodes asArray.
					self ensureNodePositions.
					golap updateItemsList ] ]
]
