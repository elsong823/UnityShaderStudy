Shader "MyShader/c8/testNormalShader"
{
	Properties
	{
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Albedo("Albedo", 2D) = "white"{}
		_BumpMap("BumpMap", 2D) = "bump"{}
		_BumpScale("BumpScale", Float) = 1.0
		_SpecularMap("SpecularMap", 2D) = "white"{}
		_SpecularScale("SpacularScale", Float) = 1.0
		_Shininess("Shininess", Range(8, 256)) = 128
	}

	SubShader
	{
		Tags
		{
			"LightMode" = "ForwardBase"
			"Queue" = "Geometry"
		}
		Pass
		{
			CGPROGRAM

			#pragma vertex Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _Albedo;
			float4 _Albedo_ST;
			sampler2D _BumpMap;
			float _BumpScale;
			sampler2D _SpecularMap;
			float _SpecularScale;
			float _Shininess;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 t2w_0 : TEXCOORD1;
				float4 t2w_1 : TEXCOORD2;
				float4 t2w_2 : TEXCOORD3;
			};

			v2f Vert(a2v i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.uv.xy = TRANSFORM_TEX(i.texcoord, _Albedo);

				fixed3 worldNormal = UnityObjectToWorldNormal( i.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( i.tangent.xyz );
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * i.tangent.w;

				fixed3 worldPos = mul(_Object2World, i.vertex).xyz;

				o.t2w_0.w = worldPos.x;
				o.t2w_1.w = worldPos.y;
				o.t2w_2.w = worldPos.z;

				o.t2w_0.xyz = float3(worldTangent.x, worldBinormal.x, worldNormal.x);
				o.t2w_1.xyz = float3(worldTangent.y, worldBinormal.y, worldNormal.y);
				o.t2w_2.xyz = float3(worldTangent.z, worldBinormal.z, worldNormal.z);

				return o;
			}

			fixed4 Frag(v2f i) : SV_Target
			{	
				fixed3 worldPos = float3(i.t2w_0.w, i.t2w_1.w, i.t2w_2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir( worldPos ));
				fixed3 worldView = normalize(UnityWorldSpaceViewDir( worldPos ));
				fixed3 worldHalf = normalize(worldLight + worldView);
				fixed3 packedNormal = UnpackNormal( tex2D(_BumpMap, i.uv.xy) );
				packedNormal.xy *= _BumpScale;
				packedNormal.z = sqrt(1.0 - saturate(dot(packedNormal.xy, packedNormal.xy)));
 				fixed3 worldNormal =normalize( half3(dot(i.t2w_0.xyz, packedNormal), dot(i.t2w_1.xyz, packedNormal), dot(i.t2w_2.xyz, packedNormal)) );

				fixed3 albedo = tex2D(_Albedo, i.uv.xy);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;

				fixed3 diffuse = _LightColor0 * albedo * saturate(dot(worldLight, worldNormal));

				fixed3 specular = _LightColor0 * pow(saturate(dot(worldHalf, worldNormal)), _Shininess) * tex2D(_SpecularMap, i.uv.xy).r * _SpecularScale;

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Specular"

}