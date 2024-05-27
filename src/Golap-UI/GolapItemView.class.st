Class {
	#name : 'GolapItemView',
	#superclass : 'SpPresenter',
	#instVars : [
		'infoList',
		'itemImage',
		'golap',
		'node'
	],
	#classVars : [
		'EmptyImage',
		'ImageRepositoryUrl'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'layout' }
GolapItemView class >> defaultLayout [

	<spec>
	^ SpPanedLayout newVertical
		  positionOfSlider: 0.6;
		  add: #infoList;
		  add: #itemImage;
		  yourself
]

{ #category : 'instance creation' }
GolapItemView class >> on: aGolap [

	^ self new
		  golap: aGolap;
		  yourself
]

{ #category : 'accessing' }
GolapItemView >> emptyImage [
	^ EmptyImage
		ifNil: [ | image |
			image := Form extent: 16 @ 16 depth: 32.
			image getCanvas fillColor: Color white.
			image ]
]

{ #category : 'accessing' }
GolapItemView >> golap: aGolap [
	golap := aGolap
]

{ #category : 'initialization' }
GolapItemView >> initializePresenters [

	infoList := self newTable
		            enabled: false;
		            addColumn:
			            (SpStringTableColumn new evaluated: [ :assoc |
					             assoc key asString ]);
		            addColumn:
			            (SpStringTableColumn new evaluated: [ :assoc |
					             assoc value asString ]);
		            yourself.
	itemImage := self newImage
		             switchAutoscale;
		             yourself
]

{ #category : 'accessing' }
GolapItemView >> node: aGolapNode [

	node := aGolapNode.
	[
	self updateImage.
	self updateItemInfo ] forkAt: Processor userBackgroundPriority
]

{ #category : 'snapshot' }
GolapItemView >> restore: aStream [

	(NeoJSONReader on: aStream) next ifNotNil: [ :json |
		golap productInfoRetriever:
			(GolapProductInfoRetriever fromJSON: json) ]
]

{ #category : 'snapshot' }
GolapItemView >> snapshot [

	golap snapshotItemView: [ :stream | self snapshotInto: stream ]
]

{ #category : 'snapshot' }
GolapItemView >> snapshotInto: aStream [

	(NeoJSONWriter on: aStream) nextPut:
		golap productInfoRetriever asJSON
]

{ #category : 'updating' }
GolapItemView >> updateImage [

	node ifNotNil: [
		golap productInfoRetriever ifNotNil: [ :retriever |
			retriever hasPhotoImage ifTrue: [
				(retriever photoimageFor: node) ifNotNil: [ :photoimage |
					node photoimage ifNil: [
						node photoimage: (photoimage scaledToSize: 64 @ 64) ].
					itemImage image: photoimage.
					^ self ] ] ] ].
	itemImage image: self emptyImage
]

{ #category : 'updating' }
GolapItemView >> updateItemInfo [

	^ infoList items: ((node ifNotNil: [
			    golap productInfoRetriever ifNotNil: [ :retriever |
				    retriever productDataFor: node ] ]) ifNil: [ #(  ) ])
]
