Class {
	#name : 'GolapGraphOverviewNodeInteraction',
	#superclass : 'GolapOverviewNodeInteraction',
	#category : 'Golap-Visualization-Overview',
	#package : 'Golap-Visualization',
	#tag : 'Overview'
}

{ #category : 'hooks' }
GolapGraphOverviewNodeInteraction >> onShape: aCanvas [

	super onShape: aCanvas.
	aCanvas when: RSMouseDragging send: #processMouseDragging: to: self
]

{ #category : 'event processing' }
GolapGraphOverviewNodeInteraction >> processMouseDragging: evt [

	self retractItemInfo: evt.
	evt shiftKeyPressed ifTrue: [
			presenter drag: evt shape model by: evt.
			evt canvas signalUpdate ]
]

{ #category : 'rendering' }
GolapGraphOverviewNodeInteraction >> renderLegendOn: legend [

	super renderLegendOn: legend.
	legend text: 'アイテム上でシフト+ドラッグ' description: 'アイテムを一時移動する'
]
