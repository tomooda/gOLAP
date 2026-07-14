Class {
	#name : 'GolapOverviewNodeInteraction',
	#superclass : 'RSAbstractControlCanvasInteraction',
	#instVars : [
		'presenter',
		'popup'
	],
	#category : 'Golap-Visualization-Overview',
	#package : 'Golap-Visualization',
	#tag : 'Overview'
}

{ #category : 'private' }
GolapOverviewNodeInteraction >> createLabelFor: aCollectionOfAssociations [

	| top left labels |
	top := 0.
	left := 0.
	labels := RSGroup new.
	aCollectionOfAssociations do: [ :assoc |
			| label |
			label := RSLabel new
				         text: assoc key asString , ':';
				         color: Color black;
				         yourself.
			label translateTopLeftTo: left @ top.
			labels add: label.
			top := label encompassingRectangle bottom ].
	top := 0.
	left := labels encompassingRectangle right + 5.
	aCollectionOfAssociations do: [ :assoc |
			| label |
			label := RSLabel new
				         text: assoc value asString;
				         color: Color black;
				         yourself.
			label translateTopLeftTo: left @ top.
			labels add: label.
			top := label encompassingRectangle bottom ].
	labels addFirst: (RSBox new
			 color: (Color fromHexString: 'E6F2F7');
			 origin: labels encompassingRectangle origin - (5 @ 5)
			 corner: labels encompassingRectangle corner + (5 @ 5);
			 yourself).
	^ labels asShape translateTo: 0 @ 0
]

{ #category : 'private' }
GolapOverviewNodeInteraction >> createPopup: event [

	presenter golapDo: [ :golap |
			(event shape ifNotNil: #model) ifNotNil: [ :node |
					(golap retrieveItemInfoFor: node) ifNotNil: [ :itemInfo |
						(self createLabelFor: itemInfo) ifNotNil: [ :label | ^ label ] ] ] ].
	^ nil
]

{ #category : 'hooks' }
GolapOverviewNodeInteraction >> onShape: aCanvas [

	aCanvas
		when: RSMouseLeftClick send: #processMouseLeftClick: to: self;
		when: RSMouseRightClick send: #processMouseRightClick: to: self;
		when: RSMouseDragging send: #processMouseDragging: to: self;
		when: RSMouseEnter send: #popupItemInfo: to: self;
		when: RSMouseLeave send: #retractItemInfo: to: self
]

{ #category : 'event processing' }
GolapOverviewNodeInteraction >> popupItemInfo: event [

	popup ifNil: [ popup := self createPopup: event ].
	popup position: event shape encompassingRectangle rightCenter
		+ (popup encompassingRectangle width // 2 @ 0).
	event canvas addShape: popup.
	event canvas signalUpdate
]

{ #category : 'accessing' }
GolapOverviewNodeInteraction >> presenter [

	^ presenter
]

{ #category : 'accessing' }
GolapOverviewNodeInteraction >> presenter: aGolapOverviewPresenter [

	presenter := aGolapOverviewPresenter
]

{ #category : 'event processing' }
GolapOverviewNodeInteraction >> processMouseDragging: evt [

	self retractItemInfo: evt.
	evt shiftKeyPressed ifTrue: [
			presenter drag: evt shape model by: evt.
			evt canvas signalUpdate ]
]

{ #category : 'event processing' }
GolapOverviewNodeInteraction >> processMouseLeftClick: evt [

	self retractItemInfo: evt.
	presenter golapDo: [ :golap |
			evt shape model ifNotNil: [ :node |
				(node isKindOf: GolapNode) ifTrue: [ golap toggleSelection: node ] ] ]
]

{ #category : 'event processing' }
GolapOverviewNodeInteraction >> processMouseRightClick: evt [

	self retractItemInfo: evt.
	(evt shape model isKindOf: GolapNode) ifTrue: [
			presenter golapDo: [ :golap |
				(golap globalImageMenu: evt shape model) openWithSpecAtPointer ] ]
]

{ #category : 'rendering' }
GolapOverviewNodeInteraction >> renderLegendOn: legend [

	legend
		text: 'アイテム上でシフト+ドラッグ' description: 'アイテムを一時移動する';
		text: 'アイテムをクリック' description: 'アイテムを選択/選択解除する';
		text: 'アイテム上で右クリック' description: '商品メニュー'
]

{ #category : 'event processing' }
GolapOverviewNodeInteraction >> retractItemInfo: event [

	popup ifNotNil: [
			popup remove.
			event canvas signalUpdate.
			popup := nil ]
]
