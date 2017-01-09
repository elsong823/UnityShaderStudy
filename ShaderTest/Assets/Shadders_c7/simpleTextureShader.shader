Shader "MyShader/c7/simpleTextureShader"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex("MainTex", 2D) = ""{}
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8, 256)) = 32
		_UseHalf("UseHalf", int) = 1
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

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldFragPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;
			int _UseHalf;

			v2f Vert(in appdata_base i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldFragPos = mul(_Object2World, i.vertex).xyz;
				o.uv = i.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
//				o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);

				return o;
			}

			fixed4 Frag(in v2f i) : SV_Target
			{
				//Calc vector
				fixed3 worldLight = normalize( _WorldSpaceLightPos0 );
				fixed3 worldNormal = normalize( i.worldNormal );
				fixed3 worldView = normalize( _WorldSpaceCameraPos - i.worldFragPos );
				fixed3 worldHalf = normalize( worldLight + worldView );
				fixed3 worldReflect = normalize( reflect(-worldLight, worldNormal) );

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;

				fixed3 diffuse = _LightColor0 * albedo * saturate( dot(worldLight, worldNormal) );

				fixed3 specular = fixed3(0.0, 0.0, 0.0);

				if(_UseHalf > 0)
					specular = _LightColor0 * _Specular * pow(saturate( dot(worldHalf, worldNormal) ), _Gloss);
				else
					specular = _LightColor0 * _Specular * pow(saturate( dot(worldReflect, worldView) ), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"
}