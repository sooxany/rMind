"""Analyzer module.

이 모듈은 프로젝트 내의 기존 구현(`test_data/save_data.py`, `RPPG-BPM-master/main.py`)
에서 함수들을 동적으로 import 하여 외부에 재노출합니다. FastAPI 엔드포인트는
이 모듈만 import 한 뒤 함수들을 사용하도록 하여, 실제 구현 파일이 변경되더라도
의존성을 한 곳에서 관리할 수 있게 합니다.
"""
from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
from types import ModuleType
from typing import Callable

BASE_DIR = Path(__file__).resolve().parent.parent  # rppg_project/


def _load_module(module_name: str, file_path: Path) -> ModuleType:
    """주어진 파일 경로에서 모듈을 동적으로 로드한다."""
    spec = importlib.util.spec_from_file_location(module_name, str(file_path))
    if spec is None or spec.loader is None:  # pragma: no cover
        raise ImportError(f"Unable to load module {module_name} from {file_path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module  # 캐시에 등록
    spec.loader.exec_module(module)  # type: ignore[attr-defined]
    return module


# ---------------------------------------------------------------------------
# 1) extract_features_from_video – test_data/save_data.py
# ---------------------------------------------------------------------------
save_data_path = BASE_DIR / "test_data" / "save_data.py"
_save_data_mod = _load_module("_save_data", save_data_path)
extract_features_from_video: Callable = _save_data_mod.extract_features_from_video  # type: ignore[attr-defined]


# ---------------------------------------------------------------------------
# 2) analyze_and_plot – RPPG-BPM-master/main.py
#    하이픈(-)이 포함된 디렉터리는 파이썬 패키지로 바로 임포트할 수 없으므로
#    파일 경로 기반 동적 로딩을 사용한다.
# ---------------------------------------------------------------------------
main_path = BASE_DIR / "RPPG-BPM-master" / "main.py"
_rppg_main_mod = _load_module("_rppg_main", main_path)
analyze_and_plot: Callable = _rppg_main_mod.analyze_and_plot  # type: ignore[attr-defined]

__all__ = [
    "extract_features_from_video",
    "analyze_and_plot",
] 