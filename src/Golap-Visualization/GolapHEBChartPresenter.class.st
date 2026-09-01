Class {
	#name : 'GolapHEBChartPresenter',
	#superclass : 'GolapOverviewPresenter',
	#instVars : [
		'attributeDropList',
		'nodeCategories',
		'categoryNodes',
		'visibleNodes',
		'nodeAngles',
		'categoryAngles'
	],
	#category : 'Golap-Visualization-HEB',
	#package : 'Golap-Visualization',
	#tag : 'HEB'
}

{ #category : 'enumerating' }
GolapHEBChartPresenter >> categoriesDo: aBlock [

	self ensureCategories.
	categoryNodes keysDo: aBlock
]

{ #category : 'enumerating' }
GolapHEBChartPresenter >> category: aString nodesDo: aBlock [

	self ensureCategories.
	categoryNodes at: aString ifPresent: [ :nodes | nodes do: aBlock ]
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> categoryPositionAt: aString [

	^ aString
		  ifNotNil: [ categoryAngles at: aString ifPresent: [ :angles | self pointAtRadius: self radius * 0.5 theta: angles average ] ]
		  ifNil: [ self pointAtRadius: 0.0 theta: 0.0 ]
]

{ #category : 'layout' }
GolapHEBChartPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: '分類に使う属性' expand: false;
				   add: attributeDropList expand: false)
		  expand: false;
		  add: roassal
]

{ #category : 'initialization' }
GolapHEBChartPresenter >> defaultScale [

	^ 1.0
]

{ #category : 'operations' }
GolapHEBChartPresenter >> doZoomToFit [

	^ self canvas zoomToFit
]

{ #category : 'updating' }
GolapHEBChartPresenter >> ensureAngles [

	(nodeAngles isNil or: [ categoryAngles isNil ]) ifTrue: [ self updateAngles ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> ensureAttributes [

	attributeDropList items size < 2 ifTrue: [ self updateAttributeDropList ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> ensureCategories [

	(nodeCategories isNil or: [ categoryNodes isNil ]) ifTrue: [ self updateCategories ]
]

{ #category : 'private' }
GolapHEBChartPresenter >> evens: aSequenceableCollection [

	^ (2 to: aSequenceableCollection size by: 2) collect: [ :index | aSequenceableCollection at: index ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> flushAngles [

	nodeAngles := categoryAngles := nil
]

{ #category : 'updating' }
GolapHEBChartPresenter >> flushCategories [

	nodeCategories := categoryNodes := visibleNodes := nil.
	self flushAngles
]

{ #category : 'updating' }
GolapHEBChartPresenter >> golapChanged [

	self updateAttributeDropList.
	self updateCanvas
]

{ #category : 'initialization' }
GolapHEBChartPresenter >> initializePresenters [

	super initializePresenters.
	attributeDropList := self newDropList
		                     display: [ :item | item ifNil: '-- なし --' ];
		                     items: { nil };
		                     selectFirst;
		                     whenSelectedItemChangedDo: [ self selectedAttributeChanged ];
		                     yourself
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> innerRadius [

	^ 50
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newLabelForNode: nodeId [

	^ self golapModelDo: [ :golapModel |
			  golapModel nodeAt: nodeId ifPresent: [ :node |
					  nodeAngles at: nodeId ifPresent: [ :theta |
							  | label delta |
							  label := RSLabel new
								           text: node name;
								           yourself.
							  delta := label width + self nodeSize * 0.5 + 10.0.
							  label
								  color: (self colorForNode: node);
								  rotateByRadians: theta + (Float pi / 2.0) \\ Float pi - (Float pi / 2.0);
								  position: (self nodePositionAt: nodeId offset: delta);
								  yourself ] ] ]
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newPieForCategory: aString [

	^ categoryAngles at: aString ifPresent: [ :angles |
			  | alpha beta |
			  alpha := angles max negated * 180.0 / Float pi % 360.0.
			  beta := angles min negated * 180.0 / Float pi % 360.0.
			  beta < alpha ifTrue: [ beta := beta + 360.0 ].
			  RSPieSlice new
				  alphaAngle: alpha;
				  betaAngle: beta;
				  innerRadius: self innerRadius * scale;
				  externalRadius: self radius - self innerRadius * scale;
				  color: (Color h: angles average * 180.0 / Float pi % 360.0 s: 0.05 v: 1.0);
				  position: (self pointAtRadius: 0.0 theta: 0.0);
				  yourself ]
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newShapeForCategory: aString [

	^ (self categoryPositionAt: aString) ifNotNil: [ :position |
			  RSLabel new
				  text: aString;
				  color: Color gray;
				  position: position;
				  yourself ]
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newShapeForEdge: pair [

	| node1 node2 category1 category2 |
	node1 := pair first.
	node2 := pair second.
	category1 := nodeCategories at: node1 ifAbsent: [ nil ].
	category2 := nodeCategories at: node2 ifAbsent: [ nil ].
	^ category1 = category2
		  ifTrue: [ self newShapeForEdgeBetween: node1 and: node2 category: category1 ]
		  ifFalse: [
				  self
					  newShapeForEdgeBetween: node1
					  category: category1
					  and: node2
					  category: category2 ]
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newShapeForEdgeBetween: node1 and: node2 category: category [

	| p1 p2 p3 |
	p1 := (self nodePositionAt: node1) ifNil: [ ^ nil ].
	p2 := (self categoryPositionAt: category) ifNil: [ ^ nil ].
	p3 := (self nodePositionAt: node2) ifNil: [ ^ nil ].
	^ RSUniformCubicBSpline new
		  controlPoints: {
				  p1.
				  p2.
				  p3 };
		  capRound;
		  yourself
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newShapeForEdgeBetween: node1 category: category1 and: node2 category: category2 [

	| p1 p2 p3 p4 |
	p1 := (self nodePositionAt: node1) ifNil: [ ^ nil ].
	p2 := (self categoryPositionAt: category1) ifNil: [ ^ nil ].
	p3 := (self categoryPositionAt: category2) ifNil: [ ^ nil ].
	p4 := (self nodePositionAt: node2) ifNil: [ ^ nil ].
	^ RSUniformCubicBSpline new
		  controlPoints: {
				  p1.
				  p2.
				  p3.
				  p4 };
		  capRound;
		  yourself
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newShapeForNode: nodeId [

	^ self golapModelDo: [ :golapModel |
			  nodeAngles at: nodeId ifPresent: [ :theta |
					  RSBox new
						  extent: self nodeSize asPoint;
						  color: (self colorForNode: nodeId);
						  model: (golapModel nodeAt: nodeId);
						  rotateByRadians: theta + (Float pi / 2.0) \\ Float pi - (Float pi / 2.0);
						  position: (self nodePositionAt: nodeId offset: self nodeSize * 0.5);
						  yourself ] ]
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> nodePositionAt: aString [

	^ self nodePositionAt: aString offset: 0.0
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> nodePositionAt: aString offset: aNumber [

	^ nodeAngles at: aString ifPresent: [ :theta | self pointAtRadius: aNumber / scale + self radius theta: theta ]
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> nodeSize [

	^ 10
]

{ #category : 'private' }
GolapHEBChartPresenter >> odds: aSequenceableCollection [

	^ (1 to: aSequenceableCollection size by: 2) collect: [ :index | aSequenceableCollection at: index ]
]

{ #category : 'private' }
GolapHEBChartPresenter >> peakCentered: aDescendingCollection [
	"self new peakCentered: #(10 9 8 7 6 5 4 3 2 1)"
	"self new peakCentered: #(9 8 7 6 5 4 3 2 1)"

	^ (self evens: aDescendingCollection) reversed , (self odds: aDescendingCollection)
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> pointAtRadius: radius theta: theta [

	^ (Point r: radius theta: theta) + offset * scale
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> radius [

	^ 400
]

{ #category : 'rendering' }
GolapHEBChartPresenter >> renderCategoriesIn: aCanvas [

	self ensureAngles.
	categoryAngles keysDo: [ :category |
			(self newPieForCategory: category) ifNotNil: [ :shape | aCanvas add: shape ].
			(self newShapeForCategory: category) ifNotNil: [ :shape | aCanvas add: shape ] ]
]

{ #category : 'rendering' }
GolapHEBChartPresenter >> renderEdgesIn: aCanvas [

	| pulls |
	self ensureCategories.
	pulls := OrderedCollection new.
	self golapModelDo: [ :golapModel |
			golapModel edgesDo: [ :edge |
					(self colorForEdge: edge) ifNotNil: [ :color |
							(self newShapeForEdge: edge key) ifNotNil: [ :shape |
									shape
										color: (color alpha: 0.5);
										width: (golapModel normalizedValueAtEdge: edge) * 10.
									aCanvas add: shape.
									((golap includesSelection: edge node1) or: [ golap includesSelection: edge node2 ]) ifTrue: [ pulls add: shape ] ] ] ].
			pulls do: [ :shape | shape pushFront ] ]
]

{ #category : 'rendering' }
GolapHEBChartPresenter >> renderNodesIn: aCanvas [

	self ensureAngles.
	nodeAngles keysDo: [ :nodeId |
			(self newShapeForNode: nodeId) ifNotNil: [ :shape | aCanvas add: shape ].
			(self newLabelForNode: nodeId) ifNotNil: [ :shape | aCanvas add: shape ] ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> scaleAndOffsetChanged [

	self updateCanvas
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> selectedAttribute [

	^ attributeDropList selectedItem
]

{ #category : 'updating' }
GolapHEBChartPresenter >> selectedAttributeChanged [

	self flushCategories.
	self updateCanvas
]

{ #category : 'testing' }
GolapHEBChartPresenter >> showsNode: aGolapNode [

	^ aGolapNode isIsolated not
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateAngles [

	| theta delta newNodeAngles newCategoryAngles |
	self ensureCategories.
	theta := 0.0.
	delta := Float pi * 2.0 / (visibleNodes size + categoryNodes size) asFloat.
	newNodeAngles := Dictionary new.
	newCategoryAngles := Dictionary new.
	self categoriesDo: [ :category |
			| minTheta maxTheta |
			minTheta := maxTheta := theta.
			self category: category nodesDo: [ :node |
					newNodeAngles at: node put: theta.
					maxTheta := theta := theta + delta ].
			category ifNotNil: [
					newCategoryAngles at: category put: {
							(minTheta - delta).
							maxTheta }.
					theta := theta + delta ] ].
	nodeAngles := newNodeAngles.
	categoryAngles := newCategoryAngles
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateAttributeDropList [

	(golap itemInfoRetriever ifNotNil: #attributeNames) ifNotNil: [ :names |
			| selection |
			selection := attributeDropList selectedItem.
			attributeDropList items: { nil } , names.
			(attributeDropList items includes: selection) ifTrue: [ attributeDropList selectItem: selection ] ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateCanvas [

	self isDisplayed ifTrue: [
			self critical: [
					self ensureAttributes.
					self canvas shapes copy do: #remove.
					self
						renderCategoriesIn: self canvas;
						renderNodesIn: self canvas;
						renderEdgesIn: self canvas.
					self canvas signalUpdate ] ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateCategories [

	self ensureAttributes.
	self golapModelDo: [ :golapModel |
			| nodeValues newCategoryNodes newNodeCategories |
			visibleNodes := golap nodes reject: #isIsolated.
			nodeValues := Dictionary new: visibleNodes size.
			visibleNodes do: [ :node | nodeValues at: node id put: ((golapModel normalizedValueAtNode: node) ifNil: [ 0.0 ]) ].
			newCategoryNodes := Dictionary new.
			newNodeCategories := Dictionary new.
			self selectedAttribute
				ifNotNil: [ :attribute |
						GolapProgressDialog new
							title: '分類情報取得中…';
							informUserDuring: [ :progress |
									(golap itemInfoRetriever
										 productDataAt: attribute
										 forAll: visibleNodes
										 interim: [ :p | progress progressPercent: p * 100.0 ]) keysAndValuesDo: [ :id :category |
												newNodeCategories at: id put: category.
												(newCategoryNodes at: category ifAbsentPut: [ OrderedCollection new ]) add: id ] ] ]
				ifNil: [
						newCategoryNodes at: nil put: (visibleNodes asOrderedCollection collect: #id).
						visibleNodes do: [ :node | newNodeCategories at: node id put: nil ] ].
			nodeCategories := newNodeCategories.
			categoryNodes := (self peakCentered: (((newCategoryNodes associations collect: [ :assoc |
						                     assoc key
						                     ->
						                     (self peakCentered: (assoc value sorted: [ :node | nodeValues at: node ifAbsent: [ 0.0 ] ] descending))
						                     -> (assoc value collect: [ :node | nodeValues at: node ifAbsent: [ 0.0 ] ]) sum ]) sorted:
					                    #value descending) collect: #key)) asOrderedDictionary ]
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> visibleNodes [

	visibleNodes ifNil: [ self updateCategories ].
	^ visibleNodes
]
