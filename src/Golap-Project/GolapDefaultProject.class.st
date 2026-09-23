Class {
	#name : 'GolapDefaultProject',
	#superclass : 'GolapProject',
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'accessing' }
GolapDefaultProject >> projectFile [

	^ self class projectBaseDirectory / '' withExtension: self class fileExtension
]

{ #category : 'accessing' }
GolapDefaultProject >> projectName [

	^ 'gOLAP'
]
