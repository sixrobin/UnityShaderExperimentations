// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Drunk" {
	
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_strength("Strength", float) = 2
		_amplitude("Amplitude", float) = 0.5
		_speed("Time Controller", float) = 1
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _strength;
	float _amplitude;
	float _speed;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float rand() 
	{
		return (sin(dot(-_amplitude, _amplitude)));
	}

	float4 frag(v2f i) : SV_Target 
	{
		float2 blurs[4] =	
		{
			-_amplitude, -_amplitude,
			_amplitude, _amplitude,
			_amplitude, -_amplitude,
			-_amplitude, _amplitude,
		};
			
		float4 sum = (float4)0;
		sum = tex2D(_MainTex, i.uv);

		for (int j = 0; j < 4; j++)
			sum += tex2D(_MainTex, i.uv + (0.001f * _strength) * (blurs[j] + rand()) * (cos(_Time.z * _speed + j)));

		sum /= 5;
#ifdef INVERT
		sum = 1 - sum;
#endif
		return fixed4(sum);
	}

	ENDCG 
	
	Subshader 
	{
		Pass 
		{
			ZTest Always 
			Cull Off 
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature INVERT
			ENDCG
		}  
	}
	Fallback off	
}
