// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/Rainbow" {

	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
		_size("Stripes Size", float) = 0.2
		_saturation("Saturation", float) = 1
		_variation("Variation", float) = 0.5
		_speed("Speed", float) = 1
		_axis("Direction", int) = 0
	}

	CGINCLUDE	
	#include "UnityCG.cginc"
	
	struct v2f 
	{
		float4 pos	: SV_POSITION;
		float2 uv	: TEXCOORD0;
	};
	
	sampler2D _MainTex;
	float _size;
	float _saturation;
	float _variation;
	float _speed;
	int _axis;
	
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	} 
	
	float4 frag(v2f i) : SV_Target 
	{
		float4 sum = (float4)0;
	    sum = tex2D(_MainTex, i.uv);

	    float4 stripes = tex2D(_MainTex, i.uv);

		if (_axis == 0)
		{
#ifdef LOLIPOP
			stripes.r = stripes.r * sqrt(i.uv.y * 90 * _size + _Time.z * _speed) * _saturation;
#else
			stripes.r = stripes.r * sin(i.uv.y * 90 * _size + _Time.z * _speed) * _saturation;
#endif
			stripes.g = stripes.g * sin(i.uv.y * 90 * _variation * _size + _Time.z * _speed) * _saturation;
			stripes.b = stripes.b * sin(i.uv.y * 90 * (_variation/2) *_size + _Time.z * _speed) * _saturation;
		}

		if (_axis == 1) 
		{
#ifdef LOLIPOP
			stripes.r = stripes.r * sqrt(i.uv.x * 160 * _size + _Time.z * _speed) * _saturation;
#else
			stripes.r = stripes.r * sin(i.uv.x * 160 * _size + _Time.z * _speed) * _saturation;
#endif
			stripes.g = stripes.g * sin(i.uv.x * 160 * _variation * _size + _Time.z * _speed) * _saturation;
			stripes.b = stripes.b * sin(i.uv.x * 160 * (_variation/2) * _size + _Time.z * _speed) * _saturation;
		}

		if (_axis == 2)
		{
#ifdef LOLIPOP
			stripes.r = stripes.r * sqrt(i.uv.y * 90 * _size) * _saturation;
#else
			stripes.r = stripes.r * sin(i.uv.y * 90 * _size) * _saturation;
#endif
			stripes.g = stripes.g * sin(i.uv.y * 90 * _variation * _size) * _saturation;
			stripes.b = stripes.b * sin(i.uv.y * 90 * (_variation / 2) *_size) * _saturation;

#ifdef LOLIPOP
			stripes.r = stripes.r * sqrt(i.uv.x * 160 * _size + _Time.z * _speed) * _saturation;
#else
			stripes.r = stripes.r * sin(i.uv.x * 160 * _size + _Time.z * _speed) * _saturation;
#endif
			stripes.g = stripes.g * sin(i.uv.x * 160 * _variation * _size + _Time.z * _speed) * _saturation;
			stripes.b = stripes.b * sin(i.uv.x * 160 * (_variation / 2) * _size + _Time.z * _speed) * _saturation;
		}

		if (_axis == 3)
		{
#ifdef LOLIPOP
			stripes.r = stripes.r * sqrt(i.uv.y * 90 * _size + _Time.z * _speed) * _saturation;
#else
			stripes.r = stripes.r * sin(i.uv.y * 90 * _size + _Time.z * _speed) * _saturation;
#endif
			stripes.g = stripes.g * sin(i.uv.y * 90 * _variation * _size + _Time.z * _speed) * _saturation;
			stripes.b = stripes.b * sin(i.uv.y * 90 * (_variation / 2) *_size + _Time.z * _speed) * _saturation;

#ifdef LOLIPOP
			stripes.r = stripes.r * sqrt(i.uv.x * 160 * _size) * _saturation;
#else
			stripes.r = stripes.r * sin(i.uv.x * 160 * _size) * _saturation;
#endif
			stripes.g = stripes.g * sin(i.uv.x * 160 * _variation * _size) * _saturation;
			stripes.b = stripes.b * sin(i.uv.x * 160 * (_variation / 2) * _size) * _saturation;
		}

	    return fixed4(sum + stripes);
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
			#pragma shader_feature LOLIPOP
			ENDCG
		}  
	}
	Fallback off	
}
