Class {
	#name : 'GolapEdgeInteraction',
	#superclass : 'GolapChartInteraction',
	#category : 'Golap-Visualization-Clustering',
	#package : 'Golap-Visualization',
	#tag : 'Clustering'
}

{ #category : 'hooks' }
GolapEdgeInteraction >> clicked: evt [
	"evt shape model value ifNode: [ :node | node openSunburst ]."

	presenter toggleSelectionsAll:
		(evt shape model value asArray collect: [ :id |
			 presenter golap model nodeAt: id ])
]

{ #category : 'hooks' }
GolapEdgeInteraction >> createPopupFor: aShape event: event [

	| popupShape |
	popupShape := shapeBuilder shapeFor:
		              (String cr join:
			               (aShape model value idsCollect: [ :id |
				                (presenter golap model nodeAt: id) name ])).
	popupShape isFixed: true.
	event canvas addShape: popupShape.
	^ popupShape
]

{ #category : 'hooks' }
GolapEdgeInteraction >> edgeMenuFor: aGolapHierarchicalClusteringNode [

	^ presenter newMenu
		  addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Dive into';
						  action: [ presenter tree: aGolapHierarchicalClusteringNode ] ] ];
		  yourself
]

{ #category : 'hooks' }
GolapEdgeInteraction >> rightClicked: event [

	(self edgeMenuFor: event shape model value) openWithSpecAt:
		(presenter withAdapterDo: [ :a |
			 a widgetDo: [ :w | w activeHand position ] ])
]
