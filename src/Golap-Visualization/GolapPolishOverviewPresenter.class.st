Class {
	#name : 'GolapPolishOverviewPresenter',
	#superclass : 'GolapOverviewPresenter',
	#instVars : [
		'layoutButton',
		'showsPolishEdgesCheckbox',
		'polishRepeatsCheckbox',
		'polishMinClusterSize',
		'polishRemovalThresholdField',
		'polishRemovalThresholdSlider',
		'polishAdditionThresholdField',
		'polishAdditionThresholdSlider'
	],
	#category : 'Golap-Visualization-Polish',
	#package : 'Golap-Visualization',
	#tag : 'Polish'
}

{ #category : 'accessing' }
GolapPolishOverviewPresenter >> availableEdges [

	^ Array streamContents: [ :stream |
			  self golapModelDo: [ :golapModel |
					  showsPolishEdgesCheckbox state
						  ifTrue: [
						  golapModel allEdgesDo: [ :edge | stream nextPut: edge ] ]
						  ifFalse: [
						  golapModel edgesDo: [ :edge | stream nextPut: edge ] ] ] ]
]

{ #category : 'layout' }
GolapPolishOverviewPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: (SpBoxLayout newVertical
						    add: '研磨' asPresenter expand: false;
						    add: showsPolishEdgesCheckbox width: 100;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newVertical
						    add: (SpBoxLayout newHorizontal
								     add: '最小関連数' expand: false;
								     add: polishMinClusterSize width: 50;
								     yourself)
						    expand: false;
						    add: polishRepeatsCheckbox width: 100;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newVertical
						    add: polishRemovalThresholdSlider expand: true;
						    add: polishAdditionThresholdSlider expand: true;
						    yourself)
				   expand: true;
				   add: (SpBoxLayout newVertical
						    add: polishRemovalThresholdField expand: false;
						    add: polishAdditionThresholdField expand: false;
						    yourself)
				   width: 50;
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
GolapPolishOverviewPresenter >> initializePresenters [

	super initializePresenters.
	polishRepeatsCheckbox := self newCheckBox
		                         label: '繰り返し';
		                         state: false;
		                         whenChangedDo: [
			                         self repeatsPolish:
					                         polishRepeatsCheckbox state ];
		                         yourself.
	polishAdditionThresholdSlider := self newSlider
		                                 label: '+研磨';
		                                 min: 0.0;
		                                 max: 1.0;
		                                 value: 1.0;
		                                 quantum: 0.01;
		                                 whenValueChangedDo: [
				                                 polishAdditionThresholdField
					                                 number:
						                                 polishAdditionThresholdSlider
							                                 value ];
		                                 borderWidth: 0;
		                                 yourself.
	polishAdditionThresholdField := self newNumberInput
		                                beFloat;
		                                placeholder: '+研磨';
		                                minimum: 0.8;
		                                maximum: 1.0;
		                                number: 1.0;
		                                whenNumberChangedDo: [
				                                polishAdditionThresholdSlider
					                                value:
						                                polishAdditionThresholdField
							                                number.
				                                self polishAdditionThreshold:
						                                polishAdditionThresholdField
							                                number ].
	polishRemovalThresholdSlider := self newSlider
		                                label: '-研磨';
		                                min: 0.0;
		                                max: 0.2;
		                                value: 0.0;
		                                quantum: 0.01;
		                                whenValueChangedDo: [
			                                polishRemovalThresholdField
				                                number:
					                                polishRemovalThresholdSlider
						                                value ];
		                                borderWidth: 0;
		                                yourself.
	polishRemovalThresholdField := self newNumberInput
		                               beFloat;
		                               placeholder: '-研磨';
		                               minimum: 0.0;
		                               maximum: 0.2;
		                               number: 0.0;
		                               whenNumberChangedDo: [
				                               polishRemovalThresholdSlider
					                               value:
						                               polishRemovalThresholdField
							                               number.
				                               self polishRemovalThreshold:
						                               polishRemovalThresholdField
							                               number ].
	polishMinClusterSize := self newNumberInput
		                        beInteger;
		                        placeholder: '最小関連数';
		                        minimum: 1;
		                        number: 3;
		                        whenNumberChangedDo: [
			                        self polishMinClusterSize:
					                        polishMinClusterSize number ].
	showsPolishEdgesCheckbox := self newCheckBox
		                            label: '表示';
		                            state: true;
		                            whenChangedDo: [ self updateCanvas ];
		                            yourself.
	layoutButton := self newButton
		                label: ' 再配置 ';
		                action: [ self updateNodePositions ];
		                yourself
]

{ #category : 'instance creation' }
GolapPolishOverviewPresenter >> newShapeForEdge: aGolapEdge [

	^ (super newShapeForEdge: aGolapEdge) ifNotNil: [ :line |
			  showsPolishEdgesCheckbox state ifTrue: [
					  aGolapEdge isPositivePolishEdge ifTrue: [
						  line color: golap positivePolishColor ].
					  aGolapEdge isNegativePolishEdge ifTrue: [
							  line
								  color: golap negativePolishColor;
								  dashArray: #( 2 6 ) ] ].
			  line ]
]

{ #category : 'operations' }
GolapPolishOverviewPresenter >> polishAdditionThreshold: aNumber [

	golap updateGlobalImageAfter: [
			golap model polishAdditionThreshold: aNumber.
			golap announceGolapModelUpdated ]
]

{ #category : 'operations' }
GolapPolishOverviewPresenter >> polishMinClusterSize: aNumber [

	golap updateGlobalImageAfter: [
			golap model polishMinClusterSize: aNumber.
			golap announceGolapModelUpdated ]
]

{ #category : 'operations' }
GolapPolishOverviewPresenter >> polishRemovalThreshold: aNumber [

	golap updateGlobalImageAfter: [
			golap model polishRemovalThreshold: aNumber.
			golap announceGolapModelUpdated ]
]

{ #category : 'rendering' }
GolapPolishOverviewPresenter >> renderEdgesIn: aRSCanvas [

	super renderEdgesIn: aRSCanvas.
	showsPolishEdgesCheckbox state ifTrue: [
			aRSCanvas lines do: [ :line |
					line parent ifNotNil: [
							line model ifNotNil: [ :edge |
								edge isPositivePolishEdge ifTrue: [ line pushFront ] ] ] ] ]
]

{ #category : 'operations' }
GolapPolishOverviewPresenter >> repeatsPolish: aBoolean [

	golap updateGlobalImageAfter: [
			golap model repeatsPolish: aBoolean.
			golap announceGolapModelUpdated ]
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
