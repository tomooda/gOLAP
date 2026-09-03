Extension { #name : 'GolapItemsAppearance' }

{ #category : '*Golap-Project' }
GolapItemsAppearance >> asJSON [

	^ Dictionary new
		  at: 'shows-photoimage' put: showPhotoImagesCheckbox state;
		  at: 'shows-photoimage-log' put: showsPhotoimageRetrievalLogCheckbox state;
		  at: 'shows-iteminfo-popup' put: showsItemInfoPopup state;
		  yourself
]

{ #category : '*Golap-Project' }
GolapItemsAppearance >> fromJSON: aDictionary [

	aDictionary
		at: 'shows-photoimage' ifPresent: [ :bool | showPhotoImagesCheckbox state: bool ];
		at: 'shows-photoimage-log' ifPresent: [ :bool | showsPhotoimageRetrievalLogCheckbox state: bool ];
		at: 'shows-iteminfo-popup' ifPresent: [ :bool | showsItemInfoPopup state: bool ];
		yourself
]
