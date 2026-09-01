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
		(event shape ifNotNil: #model) ifNotNil: [ :node | ^ self createTemporaryLabelFor: node in: event canvas ] ].
	^ nil
]

{ #category : 'private' }
GolapOverviewNodeInteraction >> createTemporaryLabelFor: node in: aCanvas [

	| text label |
	text := RSLabel new
		        text: 'サーバから取得中';
		        yourself.
	label := {
		         (RSBox new
			          extent: text extent + (10 @ 10);
			          color: (Color fromHexString: 'E6F2F7')).
		         text } asShape.
	[
		self updatePopup: label for: node.
		aCanvas signalUpdate ] forkAt: Processor userBackgroundPriority.
	^ label
]

{ #category : 'hooks' }
GolapOverviewNodeInteraction >> onShape: aCanvas [

	aCanvas
		when: RSMouseLeftClick send: #processMouseLeftClick: to: self;
		when: RSMouseRightClick send: #processMouseRightClick: to: self;
		when: RSMouseEnter send: #popupItemInfo: to: self;
		when: RSMouseLeave send: #retractItemInfo: to: self
]

{ #category : 'event processing' }
GolapOverviewNodeInteraction >> popupItemInfo: event [

	[
		Cursor wait showWhile: [
				popup ifNil: [ popup := self createPopup: event ].
				popup position: event shape encompassingRectangle rightCenter + (popup encompassingRectangle width // 2 @ 0).
				event canvas addShape: popup.
				event canvas signalUpdate ] ] forkAt: Processor userBackgroundPriority
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
		text: 'アイテムをクリック' description: 'アイテムを選択/選択解除する';
		text: 'アイテム上で右クリック' description: '商品メニュー'
]

{ #category : 'private' }
GolapOverviewNodeInteraction >> replaceLabel: aRSComposite with: anotherRSComposite [

	popup := anotherRSComposite.
	popup position: aRSComposite position.
	aRSComposite canvas ifNotNil: [ :canvas | canvas add: popup ].
	aRSComposite remove
]

{ #category : 'event processing' }
GolapOverviewNodeInteraction >> retractItemInfo: event [

	popup ifNotNil: [
			popup remove.
			event canvas signalUpdate.
			popup := nil ]
]

{ #category : 'private' }
GolapOverviewNodeInteraction >> updatePopup: label for: node [

	presenter golapDo: [ :golap |
			(golap retrieveItemInfoFor: node) ifNotNil: [ :itemInfo |
				(self createLabelFor: itemInfo) ifNotNil: [ :newLabel | self replaceLabel: label with: newLabel ] ].
			label remove ]
]
