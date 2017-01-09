Shader "MyShader/c7/RampShader"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RampTex("RampTex", 2D) = "ramp"{}
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8, 256)) = 128
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _RampTex;
			fixed4 _Specular;
			float _Gloss;


			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldFragPos : TEXCOORD1;
			};


			v2f Vert(in appdata_base i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.worldNormal = mul(i.normal, (float3x3)_World2Object);
				o.worldFragPos = mul(_Object2World, i.vertex).xyz;

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize( i.worldNormal );
				fixed3 worldLight = normalize( _WorldSpaceLightPos0 );
				fixed3 worldView = normalize( _WorldSpaceCameraPos - i.worldFragPos );	
				fixed3 worldHalf = normalize( worldLight + worldView );

				float newUV = dot(worldNormal, worldLight) * 0.5 + 0.5;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 diffuse = _LightColor0.rgb * tex2D(_RampTex, fixed2(newUV, newUV)).rgb;

				fixed3 specular = _Specular * pow(saturate(dot(worldHalf, worldNormal)), _Gloss);


				return fixed4(ambient + diffuse + specular, 1.0);	
			}

			ENDCG
		}
	}

	Fallback "Specular"

}