Class {
	#name : 'GolapAttributePhotoImageRetrieverPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'retriever',
		'attributeList'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'layout' }
GolapAttributePhotoImageRetrieverPresenter class >> defaultLayout [

	^ SpBoxLayout newVertical add: #attributeList
]

{ #category : 'instance creation' }
GolapAttributePhotoImageRetrieverPresenter class >> on: aGolapAttributePhotoImageRetriever [

	^ self new
		  retriever: aGolapAttributePhotoImageRetriever;
		  yourself
]

{ #category : 'initialization' }
GolapAttributePhotoImageRetrieverPresenter >> initializePresenters [

	attributeList := self newList
		                 whenSelectedItemChangedDo: [
			                 self selectedAttributeChanged ];
		                 yourself
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetrieverPresenter >> retriever: aGolapAttributePhotoImageRetriever [

	retriever := aGolapAttributePhotoImageRetriever.
	attributeList
		items: aGolapAttributePhotoImageRetriever availableColumns
		selectItem: aGolapAttributePhotoImageRetriever photoColumn.
	self updateButtons
]

{ #category : 'updating' }
GolapAttributePhotoImageRetrieverPresenter >> selectedAttributeChanged [

	retriever photoColumn: attributeList selectedItem.
	self updateButtons
]

{ #category : 'updating' }
GolapAttributePhotoImageRetrieverPresenter >> updateButtons [

	self window ifNotNil: [ :window |
		window isDialog ifTrue: [
			window buttons first enabled: attributeList selectedItem notNil ] ]
]

{ #category : 'accessing' }
GolapAttributePhotoImageRetrieverPresenter >> windowTitle [

	^ '画像アイテム属性設定'
]
