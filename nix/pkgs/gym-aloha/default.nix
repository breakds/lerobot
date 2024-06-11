{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, mujoco
, gymnasium
, dm-control
, imageio
}:

buildPythonPackage rec {
  pname = "gym-aloha";
  version = "2024.05.07";
  format = "pytproject";

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "gym-aloha";
    rev = "7f19312f453f45fbe8ca8883d6250626dfa36373";
    hash = "sha256-+c+AJeADtEUaC62IDFh/aNERhWf5PcXqQ9797WXhQkA=";
  };

  propagatedBuildInputs = [
    mujoco
    gymnasium
    dm-control
    imageio
  ];

  meta = with lib; {
    description = "A gym environment for ALOHA";
    homepage = "https://github.com/huggingface/gym-aloha";
    license = licenses.asl20;
    maintainers = with maintainers; [ breakds ];
  };
}
