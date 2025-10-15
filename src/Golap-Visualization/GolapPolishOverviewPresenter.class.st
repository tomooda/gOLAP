Class {
	#name : 'GolapPolishOverviewPresenter',
	#superclass : 'GolapOverviewPresenter',
	#instVars : [
		'visibleEdgeMaxValue',
		'visibleEdgeMinValue',
		'visibleEdgeMinPercentileSlider',
		'visibleEdgeMaxPercentileSlider',
		'resetVisibleEdgePercentileButton',
		'layoutButton',
		'polishIterationCheckbox',
		'positivePolishSlider',
		'positivePolishField',
		'negativePolishSlider',
		'negativePolishField',
		'polishMinDenominatorField',
		'showsPolishEdgesCheckbox'
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
								  golapModel
									  edgesDo: [ :edge | stream nextPut: edge ];
									  negativePolishEdgesDo: [ :edge | stream nextPut: edge ] ]
						  ifFalse: [
						  golapModel edgesDo: [ :edge | stream nextPut: edge ] ] ] ]
]

{ #category : 'layout' }
GolapPolishOverviewPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: (SpBoxLayout newVertical
						    add:
							    ('関連値' asPresenter displayBackgroundColor: [
									     Color gray: 0.8 ])
						    expand: false;
						    add: resetVisibleEdgePercentileButton expand: false;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newVertical
						    add: (SpBoxLayout newHorizontal
								     add: '最小' asPresenter expand: false;
								     add: visibleEdgeMinPercentileSlider expand: false;
								     yourself)
						    expand: false;
						    add: (SpBoxLayout newHorizontal
								     add: '最大' asPresenter expand: false;
								     add: visibleEdgeMaxPercentileSlider expand: false;
								     yourself)
						    expand: false;
						    yourself)
				   expand: false;
				   add: '    ' asPresenter expand: false;
				   add: (SpBoxLayout newVertical
						    add:
							    ('研磨' asPresenter displayBackgroundColor: [
									     Color gray: 0.8 ])
						    expand: false;
						    add: showsPolishEdgesCheckbox width: 80;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newHorizontal
						    add: '最小関連数' expand: false;
						    add: polishMinDenominatorField width: 50;
						    yourself)
				   expand: false;
				   add: (SpBoxLayout newVertical
						    add: negativePolishSlider expand: false;
						    add: positivePolishSlider expand: false;
						    yourself)
				   width: 200;
				   add: (SpBoxLayout newVertical
						    add: negativePolishField expand: false;
						    add: positivePolishField expand: false;
						    yourself)
				   width: 50;
				   add: polishIterationCheckbox width: 100;
				   add: (SpBoxLayout newVertical
						    add:
							    ('更新' asPresenter displayBackgroundColor: [
									     Color gray: 0.8 ])
						    expand: false;
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
	visibleEdgeMinPercentileSlider := self newSlider
		                                  min: 0;
		                                  max: 100;
		                                  quantum: 1;
		                                  value: 0;
		                                  whenValueChangedDo: [
			                                  self updateCanvas ];
		                                  yourself.
	visibleEdgeMaxPercentileSlider := self newSlider
		                                  min: 0;
		                                  max: 100;
		                                  quantum: 1;
		                                  value: 100;
		                                  whenValueChangedDo: [
			                                  self updateCanvas ];
		                                  yourself.
	resetVisibleEdgePercentileButton := self newButton
		                                    label: 'リセット';
		                                    action: [
				                                    visibleEdgeMinPercentileSlider
					                                    value: 0.
				                                    visibleEdgeMaxPercentileSlider
					                                    value: 100 ];
		                                    yourself.
	polishIterationCheckbox := self newCheckBox
		                           label: '繰り返し';
		                           state: false;
		                           whenChangedDo: [ self polish ];
		                           yourself.
	positivePolishSlider := self newSlider
		                        label: '+研磨';
		                        min: 0.0;
		                        max: 1.0;
		                        value: 1.0;
		                        quantum: 0.01;
		                        whenValueChangedDo: [
				                        positivePolishField number:
						                        positivePolishSlider value.
				                        self polish ];
		                        borderWidth: 0;
		                        yourself.
	positivePolishField := self newNumberInput
		                       beFloat;
		                       placeholder: '+研磨';
		                       minimum: 0.8;
		                       maximum: 1.0;
		                       number: 1.0;
		                       whenSubmitDo: [ :txt |
				                       positivePolishSlider value:
						                       positivePolishField number.
				                       self polish ].
	negativePolishSlider := self newSlider
		                        label: '-研磨';
		                        min: 0.0;
		                        max: 0.2;
		                        value: 0.0;
		                        quantum: 0.01;
		                        whenValueChangedDo: [
				                        negativePolishField number:
						                        negativePolishSlider value.
				                        self polish ];
		                        borderWidth: 0;
		                        yourself.
	negativePolishField := self newNumberInput
		                       beFloat;
		                       placeholder: '-研磨';
		                       minimum: 0.0;
		                       maximum: 0.2;
		                       number: 0.0;
		                       whenSubmitDo: [ :txt |
				                       negativePolishSlider value:
						                       negativePolishField number.
				                       self polish ].
	polishMinDenominatorField := self newNumberInput
		                             beInteger;
		                             placeholder: '最小関連数';
		                             minimum: 1;
		                             number: 3;
		                             whenSubmitDo: [ :txt | self polish ].
	showsPolishEdgesCheckbox := self newCheckBox
		                            label: '表示';
		                            state: false;
		                            whenChangedDo: [ self updateCanvas ];
		                            yourself.
	layoutButton := self newButton
		                label: ' 再配置 ';
		                action: [
				                golap
					                updateGlobalImageAfter: [
						                golap model friendsEdges: golap model nodes size ]
					                layout: false.
				                self updateNodePositions ];
		                yourself
]

{ #category : 'accessing' }
GolapPolishOverviewPresenter >> negativePolishFactor [

	^ negativePolishField number ifNil: [ 0.0 ]
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
GolapPolishOverviewPresenter >> polish [

	golap updateGlobalImageAfter: [
			golap model
				repeat: (polishIterationCheckbox state
						 ifTrue: [ 100 ]
						 ifFalse: [ 1 ])
				polishAddAbove: self positivePolishFactor
				removeBelow: self negativePolishFactor
				minDenominator: polishMinDenominatorField text asString asInteger.
			golap announceGolapModelUpdated ]
]

{ #category : 'accessing' }
GolapPolishOverviewPresenter >> positivePolishFactor [

	^ positivePolishField number ifNil: [ 1.0 ]
]

{ #category : 'rendering' }
GolapPolishOverviewPresenter >> renderEdgesIn: aRSCanvas [

	super renderEdgesIn: aRSCanvas.
	showsPolishEdgesCheckbox state ifTrue: [
			aRSCanvas lines do: [ :line |
					line model ifNotNil: [ :edge |
						edge isPositivePolishEdge ifTrue: [ line pushFront ] ] ] ]
]

{ #category : 'updating' }
GolapPolishOverviewPresenter >> updateGraph [

	self golapModelDo: [ :model |
			| visibleEdges connectedNodes |
			visibleEdges := self availableEdges.
			(visibleEdges
				 collect: [ :edge | model valueAtEdge: edge ]
				 thenSelect: [ :value |
				 value notNil and: [ value asFloat isFinite ] ])
				asSortedCollection
				ifNotEmpty: [ :d |
						visibleEdgeMinValue := d at:
							                       (d size - 1
							                        * visibleEdgeMinPercentileSlider value
							                        * 0.01) rounded + 1.
						visibleEdgeMaxValue := d at:
							                       (d size - 1
							                        * visibleEdgeMaxPercentileSlider value
							                        * 0.01) rounded + 1 ]
				ifEmpty: [
						visibleEdgeMaxValue := visibleEdgeMinValue := 0.0.
						reallyVisibleEdges := Array new.
						reallyVisibleNodes := Array new.
						^ self ].
			visibleEdgeMinPercentileSlider label:
				visibleEdgeMinValue printString.
			visibleEdgeMaxPercentileSlider label:
				visibleEdgeMaxValue printString.
			reallyVisibleEdges := visibleEdges select: [ :edge |
					                      (model valueAtEdge: edge)
						                      ifNil: [ false ]
						                      ifNotNil: [ :v |
						                      v
							                      between: visibleEdgeMinValue
							                      and: visibleEdgeMaxValue ] ].
			connectedNodes := IdentitySet new: reallyVisibleEdges size.
			reallyVisibleEdges do: [ :edge |
					connectedNodes
						add: edge node1;
						add: edge node2 ].
			reallyVisibleNodes := Array streamContents: [ :stream |
					                      golap showsConnectedNodes ifTrue: [
						                      stream nextPutAll: connectedNodes ].
					                      golap nodesDo: [ :v |
							                      (connectedNodes includes: v) ifFalse: [
									                      v isIsolated
										                      ifTrue: [
										                      golap showsIsolatedNodes ifTrue: [
											                      stream nextPut: v ] ]
										                      ifFalse: [
										                      golap showsHiddenConnectionNodes
											                      ifTrue: [ stream nextPut: v ] ] ] ] ] ]
]
