Extension { #name : 'SpMorphicSliderAdapter' }

{ #category : '*Golap-UI' }
SpMorphicSliderAdapter >> buildWidget [

	| preWidget |
	preWidget := PluggableSliderMorph new
		             model: self;
		             getValueSelector: #value;
		             setValueSelector: #value:;
		             value: self absoluteValue;
		             getLabelSelector: #label;
		             max: self max;
		             min: self min;
		             quantum: self quantum;
		             setBalloonText: self help;
		             vResizing: #spaceFill;
		             hResizing: #spaceFill;
		             yourself.
	self presenter isHorizontal ifFalse: [ 
		preWidget := TransformationMorph new asFlexOf: preWidget.
		preWidget transform withAngle: 90 degreesToRadians negated ].

	self presenter whenMinChangedDo: [ :newValue | 
		preWidget min: newValue ].
	self presenter whenMaxChangedDo: [ :newValue | 
		preWidget max: newValue ].
	self presenter whenQuantumChangedDo: [ :newValue | 
		preWidget quantum: newValue ].
	self presenter whenValueChangedDo: [ :newValue | 
		preWidget scaledValue: newValue ].

	^ preWidget
]
