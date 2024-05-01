Extension { #name : 'SpCollectionListModel' }

{ #category : '*Golap-UI' }
SpCollectionListModel >> at: anIndex [

	^ collection at: anIndex ifAbsent: [ nil ]
]
