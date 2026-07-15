Class {
	#name : 'GolapPhotoImageRetrieversPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'itemInfoRetriever',
		'retrieverList',
		'addRetrieverButton',
		'removeRetrieverButton',
		'editRetrieverButton',
		'moveUpRetrieverButton',
		'moveDownRetrieverButton',
		'golap',
		'clearImageCacheButton'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'instance creation' }
GolapPhotoImageRetrieversPresenter class >> on: aGolapItemInfoRetriever [

	^ self new
		  itemInfoRetriever: aGolapItemInfoRetriever;
		  yourself
]

{ #category : 'operations' }
GolapPhotoImageRetrieversPresenter >> addRetriever [

	(self newMenu addGroup: [ :group |
			 itemInfoRetriever availablePhotoimageRetrievers do: [ :retriever |
					 group addItem: [ :item |
							 item
								 name: retriever shortDescription;
								 action: [ self addRetriever: retriever ] ] ] ])
		openWithSpecAtPointer
]

{ #category : 'operations' }
GolapPhotoImageRetrieversPresenter >> addRetriever: aGolapPhotoImageRetriever [

	| index retrievers |
	index := retrieverList selection selectedIndex.
	retrievers := itemInfoRetriever photoimageRetrievers.
	index = 0 ifTrue: [ index := retrievers size + 1 ].
	(index between: 1 and: retrievers size + 1) ifFalse: [ ^ self ].
	retrievers := (retrievers copyFrom: 1 to: index - 1)
	              , { aGolapPhotoImageRetriever }
	              , (retrievers copyFrom: index to: retrievers size).
	itemInfoRetriever photoimageRetrievers: retrievers.
	self itemInfoRetrieverChanged.
	retrieverList selectIndex: index.
	self editRetriever
]

{ #category : 'layout' }
GolapPhotoImageRetrieversPresenter >> buttonHeight [

	^ self class buttonHeight
]

{ #category : 'operations' }
GolapPhotoImageRetrieversPresenter >> clearCache [

	GolapPhotoImageRetriever clearCache.
	self golapModelDo: [ :golapModel |
		golapModel nodesDo: [ :node | node flushPhotoimage ] ]
]

{ #category : 'layout' }
GolapPhotoImageRetrieversPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: retrieverList height: self buttonHeight * 4;
		  add: (SpBoxLayout newHorizontal
				   add: addRetrieverButton width: self buttonHeight;
				   add: removeRetrieverButton width: self buttonHeight;
				   add: editRetrieverButton width: self buttonHeight;
				   add: moveUpRetrieverButton width: self buttonHeight;
				   add: moveDownRetrieverButton width: self buttonHeight;
				   yourself)
		  expand: false;
		  add: clearImageCacheButton expand: false;
		  yourself
]

{ #category : 'operations' }
GolapPhotoImageRetrieversPresenter >> editRetriever [

	retrieverList selectedItem ifNotNil: [ :retriever |
		| copy |
		copy := retriever copy.
		copy configPresenter ifNotNil: [ :presenter |
			presenter openDialog okAction: [
				retriever commit: copy.
				retrieverList refresh.
				golap ifNotNil: #ensurePhotoimageRetrievingProcess ] ] ]
]

{ #category : 'accessing' }
GolapPhotoImageRetrieversPresenter >> golap [

	^ golap
]

{ #category : 'accessing' }
GolapPhotoImageRetrieversPresenter >> golap: aGolap [

	golap := aGolap
]

{ #category : 'accessing' }
GolapPhotoImageRetrieversPresenter >> golapModelDo: aBlock [

	(golap ifNotNil: #model) ifNotNil: aBlock
]

{ #category : 'initialization' }
GolapPhotoImageRetrieversPresenter >> initializePresenters [

	retrieverList := self newTable
		                 addColumn:
			                 (SpStringTableColumn evaluated: [ :retriever |
					                  retriever shortDescription asString ]);
		                 addColumn:
			                 ((SpCheckBoxTableColumn evaluated: [ :retriever |
					                   retriever enabled ])
				                  onActivation: [ :retriever |
						                  retriever enable.
						                  retrieverList refresh ];
				                  onDeactivation: [ :retriever |
						                  retriever disable.
						                  retrieverList refresh ];
				                  width: 20);
		                 hideColumnHeaders;
		                 whenSelectedItemChangedDo: [
		                 self selectedRetrieverChanged ];
		                 yourself.
	addRetrieverButton := self newButton
		                      icon: (self iconNamed: #add);
		                      action: [ self addRetriever ];
		                      yourself.
	removeRetrieverButton := self newButton
		                         icon: (self iconNamed: #remove);
		                         action: [ self removeRetriever ];
		                         yourself.
	editRetrieverButton := self newButton
		                       icon: (self iconNamed: #edit);
		                       action: [ self editRetriever ];
		                       yourself.
	moveUpRetrieverButton := self newButton
		                         icon: (self iconNamed: #up);
		                         action: [ self moveUpRetriever ];
		                         yourself.
	moveDownRetrieverButton := self newButton
		                           icon: (self iconNamed: #down);
		                           action: [ self moveDownRetriever ];
		                           yourself.
	clearImageCacheButton := self newButton
		                         icon: (self iconNamed: #refreshCircling);
		                         label: '画像キャッシュをクリア';
		                         action: [ self clearCache ];
		                         yourself
]

{ #category : 'accessing' }
GolapPhotoImageRetrieversPresenter >> itemInfoRetriever: aGolapItemInfoRetriever [

	itemInfoRetriever := aGolapItemInfoRetriever.
	self itemInfoRetrieverChanged
]

{ #category : 'updating' }
GolapPhotoImageRetrieversPresenter >> itemInfoRetrieverChanged [

	self updateRetrieverList
]

{ #category : 'operations' }
GolapPhotoImageRetrieversPresenter >> moveDownRetriever [

	| retrievers index retriever |
	retrievers := itemInfoRetriever photoimageRetrievers.
	index := retrieverList selection selectedIndex.
	(index between: 1 and: retrievers size - 1) ifFalse: [ ^ self ].
	retriever := retrievers at: index.
	retrievers
		at: index put: (retrievers at: index + 1);
		at: index + 1 put: retriever.
	self itemInfoRetrieverChanged.
	retrieverList selectIndex: index + 1
]

{ #category : 'operations' }
GolapPhotoImageRetrieversPresenter >> moveUpRetriever [

	| retrievers index retriever |
	retrievers := itemInfoRetriever photoimageRetrievers.
	index := retrieverList selection selectedIndex.
	(index between: 2 and: retrievers size) ifFalse: [ ^ self ].
	retriever := retrievers at: index.
	retrievers
		at: index put: (retrievers at: index - 1);
		at: index - 1 put: retriever.
	self itemInfoRetrieverChanged.
	retrieverList selectIndex: index - 1
]

{ #category : 'accessing' }
GolapPhotoImageRetrieversPresenter >> photoImageRetrievers: anOrderedCollectionOfPhotoImageRetriever [

	retrieverList items: anOrderedCollectionOfPhotoImageRetriever
]

{ #category : 'operations' }
GolapPhotoImageRetrieversPresenter >> removeRetriever [

	| index retrievers |
	index := retrieverList selection selectedIndex.
	retrievers := itemInfoRetriever photoimageRetrievers.
	(index between: 1 and: retrievers size) ifFalse: [ ^ self ].
	retrievers := retrievers copyWithoutIndex: index.
	itemInfoRetriever photoimageRetrievers: retrievers.
	self itemInfoRetrieverChanged.
	retrieverList selectIndex: (index min: retrievers size)
]

{ #category : 'updating' }
GolapPhotoImageRetrieversPresenter >> selectedRetrieverChanged [

	self updateButtons
]

{ #category : 'updating' }
GolapPhotoImageRetrieversPresenter >> updateAddRetrieverButton [

	addRetrieverButton enabled: true
]

{ #category : 'updating' }
GolapPhotoImageRetrieversPresenter >> updateButtons [

	self
		updateAddRetrieverButton;
		updateRemoveRetrieverButton;
		updateEditRetrieverButton;
		updateMoveUpRetrieverButton;
		updateMoveDownRetrieverButton
]

{ #category : 'updating' }
GolapPhotoImageRetrieversPresenter >> updateEditRetrieverButton [

	editRetrieverButton enabled: (retrieverList selectedItem
			 ifNotNil: [ :retriever | retriever hasConfigPresenter ]
			 ifNil: [ false ])
]

{ #category : 'updating' }
GolapPhotoImageRetrieversPresenter >> updateMoveDownRetrieverButton [

	moveDownRetrieverButton enabled:
		(retrieverList selection selectedIndex
			 between: 1
			 and: retrieverList items size - 1)
]

{ #category : 'updating' }
GolapPhotoImageRetrieversPresenter >> updateMoveUpRetrieverButton [

	moveUpRetrieverButton enabled:
		retrieverList selection selectedIndex > 1
]

{ #category : 'updating' }
GolapPhotoImageRetrieversPresenter >> updateRemoveRetrieverButton [

	removeRetrieverButton enabled: retrieverList selectedItem notNil
]

{ #category : 'updating' }
GolapPhotoImageRetrieversPresenter >> updateRetrieverList [

	retrieverList
		unselectAll;
		items:
			(itemInfoRetriever ifNotNil: #photoimageRetrievers ifNil: [ #(  ) ]).
	self updateButtons
]

{ #category : 'accessing' }
GolapPhotoImageRetrieversPresenter >> windowTitle [

	^ 'アイテム画像設定'
]
