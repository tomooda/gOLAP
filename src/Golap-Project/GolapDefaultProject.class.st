Class {
	#name : 'GolapDefaultProject',
	#superclass : 'GolapProject',
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'testing' }
GolapDefaultProject >> exists [

	^ true
]

{ #category : 'controlling' }
GolapDefaultProject >> ifDefault: aBlock otherwise: anotherBlock [

	^ aBlock cull: self
]

{ #category : 'accessing' }
GolapDefaultProject >> projectFile [

	^ nil
]

{ #category : 'accessing' }
GolapDefaultProject >> projectName [

	^ nil
]
